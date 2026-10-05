{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.drawing;
  has = osConfig.host.has;
in
{
  options.features.drawing.enable = lib.mkEnableOption "drawing" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.drawing ];
  };
}
