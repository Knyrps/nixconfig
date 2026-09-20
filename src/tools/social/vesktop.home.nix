{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.vesktop;
  has = osConfig.host.has;
in
{
  options.features.vesktop.enable = lib.mkEnableOption "vesktop" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.vesktop ];
  };
}
