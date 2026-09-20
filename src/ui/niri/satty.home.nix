{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.satty;
in
{
  options.features.satty.enable = lib.mkEnableOption "satty" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.satty ];
  };
}
