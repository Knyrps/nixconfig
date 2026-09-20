{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.whatsapp-electron;
  has = osConfig.host.has;
in
{
  options.features.whatsapp-electron.enable = lib.mkEnableOption "whatsapp-electron" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.whatsapp-electron ];
  };
}
