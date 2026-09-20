{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.wl-clipboard;
in
{
  options.features.wl-clipboard.enable = lib.mkEnableOption "wl-clipboard" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wl-clipboard ];
  };
}
