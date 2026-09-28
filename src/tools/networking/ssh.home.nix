{ config, lib, osConfig, ... }:

let
  cfg = config.features.ssh;
  has = osConfig.host.has;
in
{
  # client-side config, so unlike the server in ssh.os.nix (which follows the
  # "ssh" role) this wants to be on every host we ssh *from*
  options.features.ssh.enable = lib.mkEnableOption "ssh client config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      # home-manager's legacy defaults warn on every rebuild and are slated for
      # removal. The only one that differs from OpenSSH's own defaults is
      # HashKnownHosts, carried over below.
      enableDefaultConfig = false;

      # work hosts name an employer's machines and accounts, so they stay out of
      # this repo. ssh keeps the first value it finds per keyword and includes
      # are emitted above the blocks below, so ~/.ssh/work.d/* wins.
      includes = lib.optional (has "work") "work.d/*";

      settings."*" = {
        HashKnownHosts = false;

        # drop dead connections after ~45s instead of hanging
        ServerAliveInterval = 15;
        ServerAliveCountMax = 3;
      };
    };
  };
}
