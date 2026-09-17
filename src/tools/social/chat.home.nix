{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.chat;
  has = osConfig.host.has;
in
{
  options.features.chat.enable = lib.mkEnableOption "chat" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
      whatsapp-electron
    ];
  };
}
