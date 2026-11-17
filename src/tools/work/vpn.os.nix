{ config, lib, pkgs, ... }:

let
  cfg = config.features.work-vpn;
  has = config.host.has;

  # ikev1 + dh2 (modp1024) for the legacy l2tp psk gateway.
  # stable (26.05) ships libreswan 5.3.3, which still uses the old ike_alg_dh.c
  # naming and has no buffer[2048] in updown.c — the KEM→KE rename and the
  # PATH-overflow patches only applied to 5.4+, so neither is carried here.
  libreswan = pkgs.libreswan.overrideAttrs (o: {
    makeFlags = o.makeFlags ++ [ "USE_DH2=true" ];
  });

  # plugin detects libreswan via ipsec --version
  plugin = (pkgs.networkmanager-l2tp.override { strongswan = libreswan; }).overrideAttrs (o: {
    configureFlags = o.configureFlags ++ [ "--enable-libreswan-dh2" ];

    # libreswan 5.4 fails ipsec up when left/right protocols differ
    postPatch = (o.postPatch or "") + ''
      substituteInPlace src/nm-l2tp-service.c \
        --replace-fail \
          ${lib.escapeShellArg "if (!use_ephemeral_port) {\n            write_config_option(fd, \"  leftprotoport=udp/l2tp\\n\");"} \
          ${lib.escapeShellArg "{\n            write_config_option(fd, use_ephemeral_port ? \"  leftprotoport=udp/%%any\\n\" : \"  leftprotoport=udp/l2tp\\n\");"}
    '';
  });
in
{
  options.features.work-vpn = {
    enable = lib.mkEnableOption "work l2tp/ipsec vpn" // {
      default = has "work" && config.features.networkmanager.enable;
    };

    profile = lib.mkEnableOption "a declarative connection profile built from secretsFile";

    secretsFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/secrets/work-vpn.env";
      description = ''
        Environment file outside this repo, defining WORK_VPN_GATEWAY,
        WORK_VPN_DOMAIN, WORK_VPN_USER, WORK_VPN_PASSWORD and WORK_VPN_PSK.
        envsubst substitutes them into the profile at activation.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.networkmanager.plugins = [ plugin ];

      systemd.tmpfiles.rules = [
        # plugin never creates it
        "d /etc/ipsec.d 0700 root root -"

        # must exist before the profile
        "d ${dirOf cfg.secretsFile} 0700 root root -"
      ];

      # /run/pluto and /var/lib/ipsec/nss
      systemd.tmpfiles.packages = [ libreswan ];

      # libreswan 5 drops ikev1 by default
      environment.etc."ipsec.conf".text = lib.mkDefault ''
        config setup
          ikev1-policy=accept

        include /etc/ipsec.d/*.conf
      '';

      # started on demand
      systemd.packages = [ libreswan ];

      # what ipsec shells out to
      systemd.services.ipsec.path = [ libreswan ] ++ (with pkgs; [
        iproute2
        procps
        nssTools
        iptables
        nettools
      ]);

      # nm spawns ipsec
      systemd.services.NetworkManager.path = [ libreswan ] ++ (with pkgs; [
        iproute2
        procps
        nssTools
        iptables
        nettools
      ]);

      # l2tp tunnel, mppe
      boot.kernelModules = [ "l2tp_ppp" "ppp_mppe" ];

      # gtk vpn editor
      environment.systemPackages = lib.optional (has "ui") pkgs.networkmanagerapplet;
    }

    (lib.mkIf cfg.profile {
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ cfg.secretsFile ];

        profiles.work-vpn = {
          connection = {
            id = "work";
            uuid = "748968cb-7e45-4072-bc4c-1417279bd2b3";
            type = "vpn";
            autoconnect = false;
          };

          vpn = {
            service-type = "org.freedesktop.NetworkManager.l2tp";
            gateway = "$WORK_VPN_GATEWAY";
            user = "$WORK_VPN_USER";
            domain = "$WORK_VPN_DOMAIN";
            user-auth-type = "password";
            password-flags = 0;
            ipsec-enabled = "yes";
            machine-auth-type = "psk";
            ipsec-psk-flags = 0;

            # pfs gets NO_PROPOSAL_CHOSEN
            ipsec-pfs = "no";

            # nat-t fails on port 1701
            ephemeral-port = "yes";
          };

          vpn-secrets = {
            password = "$WORK_VPN_PASSWORD";
            ipsec-psk = "$WORK_VPN_PSK";
          };

          ipv4.method = "auto";
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
          };
        };
      };
    })
  ]);
}
