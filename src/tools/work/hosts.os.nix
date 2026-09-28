{ config, lib, ... }:

let
  cfg = config.features.work-hosts;
  has = config.host.has;
in
{
  options.features.work-hosts = {
    enable = lib.mkEnableOption "client hostname overrides pulled from the work laptop" // {
      default = has "work" && config.features.networkmanager.enable;
    };

    dir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/work-hosts.d";
      description = ''
        Where the client host entries live, deliberately outside this repo.

        `networking.hosts` and `networking.hostFiles` are both assembled at
        build time, which would commit a client's internal names and addresses
        to a public repo and copy them into the world readable store. dnsmasq
        reads these at runtime instead, and watches them, so edits take effect
        without a rebuild or even a restart.

        `hosts/` takes /etc/hosts-format files. `dnsmasq/*.conf` takes dnsmasq
        directives, for the things a hosts file cannot express -- a wildcard is
        `address=/sub.example.invalid/127.0.0.1`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # /etc/hosts is resolved by nsswitch's `files` before `dns`, so moving these
    # into dns means dnsmasq has to answer for them authoritatively rather than
    # forward them. hostsdir does exactly that, and the vpn's own servers still
    # get everything else.
    networking.networkmanager.dns = "dnsmasq";

    environment.etc."NetworkManager/dnsmasq.d/work-hosts.conf".text = ''
      hostsdir=${cfg.dir}/hosts
      conf-dir=${cfg.dir}/dnsmasq,*.conf
    '';

    # world readable on purpose: dnsmasq re-reads these after dropping to an
    # unprivileged user. the contents are internal, not secret -- the point is
    # keeping them out of git, not out of the local filesystem.
    systemd.tmpfiles.rules = [
      "d ${cfg.dir} 0755 root root -"
      "d ${cfg.dir}/hosts 0755 root root -"
      "d ${cfg.dir}/dnsmasq 0755 root root -"
    ];
  };
}
