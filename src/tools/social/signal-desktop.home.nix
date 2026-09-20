{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.signal-desktop;
  has = osConfig.host.has;
in
{
  options.features.signal-desktop.enable = lib.mkEnableOption "signal-desktop" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.signal-desktop ];
  };
}
