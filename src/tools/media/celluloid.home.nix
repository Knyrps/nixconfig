{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.celluloid;
  has = osConfig.host.has;
in
{
  options.features.celluloid.enable = lib.mkEnableOption "celluloid" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.celluloid ];
  };
}
