{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.swaylock;
in
{
  options.features.swaylock.enable = lib.mkEnableOption "swaylock" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];
  };
}
