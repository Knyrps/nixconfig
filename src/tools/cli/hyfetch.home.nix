{ config, lib, pkgs, ... }:

let
  cfg = config.features.hyfetch;
in
{
  options.features.hyfetch.enable = lib.mkEnableOption "hyfetch" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.hyfetch ];
  };
}
