{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.features.musescore;
  has = osConfig.host.has;
in
{
  options.features.musescore.enable = lib.mkEnableOption "musescore" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.musescore ];
  };
}
