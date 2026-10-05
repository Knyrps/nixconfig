{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.loupe;
  has = osConfig.host.has;
in
{
  options.features.loupe.enable = lib.mkEnableOption "loupe" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.loupe ];
  };
}
