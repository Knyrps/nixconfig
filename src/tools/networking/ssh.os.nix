{ config, lib, ... }:

let
  cfg = config.features.ssh;
  has = config.host.has;
in
{
  options.features.ssh.enable = lib.mkEnableOption "ssh" // {
    default = has "ssh";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
