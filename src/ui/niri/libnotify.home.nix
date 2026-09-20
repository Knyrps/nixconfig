{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.libnotify;
in
{
  options.features.libnotify.enable = lib.mkEnableOption "libnotify" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];
  };
}
