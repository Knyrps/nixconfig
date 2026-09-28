{ config, lib, pkgs, ... }:

let
  cfg = config.features.work-vpn;
  has = config.host.has;

  # strongswan 6 dropped ikev1, which l2tp/ipsec with a psk needs. libreswan
  # still has it, but compiles dh2 (modp1024) out unless asked.
  libreswan = pkgs.libreswan.overrideAttrs (o: {
    makeFlags = o.makeFlags ++ [ "USE_DH2=true" ];
  });

  # the plugin picks its daemon by running the ipsec binary nixpkgs patches in
  # and matching --version, so overriding the input is enough. its own dh2
  # switch adds modp1024 to the default phase 1 proposals.
  plugin = (pkgs.networkmanager-l2tp.override { strongswan = libreswan; }).overrideAttrs (o: {
    configureFlags = o.configureFlags ++ [ "--enable-libreswan-dh2" ];
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
        # the plugin writes the psk here but never creates the directory
        "d /etc/ipsec.d 0700 root root -"

        # not gated on profile: the secrets file has to exist before the profile
        # does, or activation trips over the missing EnvironmentFile
        "d ${dirOf cfg.secretsFile} 0700 root root -"
      ];

      # /run/pluto and /var/lib/ipsec/nss
      systemd.tmpfiles.packages = [ libreswan ];

      # pluto reads this, and a per-connection config cannot override a global.
      # libreswan 5 defaults to ikev1-policy=drop, which refuses ikev1 at load.
      environment.etc."ipsec.conf".text = lib.mkDefault ''
        config setup
          ikev1-policy=accept

        include /etc/ipsec.d/*.conf
      '';

      # `ipsec start` defers to `systemctl start ipsec.service`. no wantedBy:
      # the plugin starts it on demand.
      systemd.packages = [ libreswan ];

      # `ipsec` is a shell script; these are what it and pluto shell out to.
      systemd.services.ipsec.path = [ libreswan ] ++ (with pkgs; [
        iproute2
        procps
        nssTools
        iptables
        nettools
      ]);

      # networkmanager is what spawns `ipsec`, so it needs the same set
      systemd.services.NetworkManager.path = [ libreswan ] ++ (with pkgs; [
        iproute2
        procps
        nssTools
        iptables
        nettools
      ]);

      # xl2tpd's kernel-mode pppol2tp tunnel, plus mppe if the server asks
      boot.kernelModules = [ "l2tp_ppp" "ppp_mppe" ];

      # the l2tp plugin's vpn dialog is a gtk editor nm-connection-editor loads;
      # noctalia's network panel only does wifi
      environment.systemPackages = lib.optional (has "ui") pkgs.networkmanagerapplet;
    }

    (lib.mkIf cfg.profile {
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ cfg.secretsFile ];

        # envsubst runs over this on activation. the result lands in
        # /run/NetworkManager/system-connections, read-only to the gui.
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

            # quick mode with pfs gets NO_PROPOSAL_CHOSEN
            ipsec-pfs = "no";

            # nat traversal does not work for l2tp from behind a nat while the
            # source port is 1701
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
