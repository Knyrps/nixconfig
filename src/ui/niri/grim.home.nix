{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.grim;
in
{
  options.features.grim.enable = lib.mkEnableOption "grim" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.grim ];
  };
}
