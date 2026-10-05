{ config, lib, osConfig, ... }:

let
  cfg = config.features.ssh;
  has = osConfig.host.has;
in
{
  # every host, unlike the server
  options.features.ssh.enable = lib.mkEnableOption "ssh client config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      # legacy defaults are deprecated
      enableDefaultConfig = false;

      # private hosts, included first
      includes = lib.optional (has "work") "work.d/*";

      settings."*" = {
        HashKnownHosts = false;

        # drop dead links after ~45s
        ServerAliveInterval = 15;
        ServerAliveCountMax = 3;
      };
    };
  };
}
