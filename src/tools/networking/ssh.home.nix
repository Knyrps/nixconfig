{ config, lib, ... }:

let
  cfg = config.features.ssh;
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

      settings."*" = {
        HashKnownHosts = false;

        # drop dead connections after ~45s instead of hanging
        ServerAliveInterval = 15;
        ServerAliveCountMax = 3;
      };
    };
  };
}
