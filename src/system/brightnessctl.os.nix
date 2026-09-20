{ config, lib, pkgs, ... }:

let
  cfg = config.features.brightnessctl;
in
{
  options.features.brightnessctl.enable = lib.mkEnableOption "brightnessctl" // {
    default = config.features.power.enable;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.brightnessctl ];
  };
}
