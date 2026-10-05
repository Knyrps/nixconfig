{ config, lib, ... }:

let
  cfg = config.features.work-hosts;
  has = config.host.has;
in
{
  options.features.work-hosts = {
    enable = lib.mkEnableOption "client hostname overrides for work" // {
      default = has "work" && config.features.networkmanager.enable;
    };

    dir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/work-hosts.d";
      description = ''
        Host entries outside this repo, since networking.hosts and
        networking.hostFiles are both assembled at build time. dnsmasq reads
        and watches these at runtime, so edits need no rebuild.

        `hosts/` takes /etc/hosts-format files, `dnsmasq/*.conf` takes dnsmasq
        directives for what a hosts file cannot express.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # nsswitch checks files before dns
    networking.networkmanager.dns = "dnsmasq";

    environment.etc."NetworkManager/dnsmasq.d/work-hosts.conf".text = ''
      hostsdir=${cfg.dir}/hosts
      conf-dir=${cfg.dir}/dnsmasq,*.conf
    '';

    # readable by dnsmasq
    systemd.tmpfiles.rules = [
      "d ${cfg.dir} 0755 root root -"
      "d ${cfg.dir}/hosts 0755 root root -"
      "d ${cfg.dir}/dnsmasq 0755 root root -"
    ];
  };
}
