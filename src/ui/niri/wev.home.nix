{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.wev;
in
{
  options.features.wev.enable = lib.mkEnableOption "wev" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wev ];
  };
}
