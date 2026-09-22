{ config, lib, pkgs, ... }:

let
  cfg = config.features.unzip;
in
{
  options.features.unzip.enable = lib.mkEnableOption "unzip" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unzip ];
  };
}
