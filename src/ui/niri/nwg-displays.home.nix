{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.nwg-displays;
in
{
  options.features.nwg-displays.enable = lib.mkEnableOption "nwg-displays" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nwg-displays ];
  };
}
