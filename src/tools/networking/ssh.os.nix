{ config, lib, ... }:

let
  cfg = config.features.ssh;
  has = config.host.has;
in
{
  options.features.ssh = {
    enable = lib.mkEnableOption "ssh" // {
      default = has "ssh";
    };
    unsafe = lib.mkEnableOption "password login";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = cfg.unsafe;
        KbdInteractiveAuthentication = cfg.unsafe;
      };
    };
  };
}
