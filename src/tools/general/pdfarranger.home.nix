{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.pdfarranger;
  has = osConfig.host.has;
in
{
  options.features.pdfarranger.enable = lib.mkEnableOption "pdfarranger" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pdfarranger ];
  };
}
