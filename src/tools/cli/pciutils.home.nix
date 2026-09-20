{ config, lib, pkgs, ... }:

let
  cfg = config.features.pciutils;
in
{
  options.features.pciutils.enable = lib.mkEnableOption "pciutils" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pciutils ];
  };
}
