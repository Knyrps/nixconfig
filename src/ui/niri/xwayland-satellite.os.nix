{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.features.xwayland-satellite;
in
{
  options.features.xwayland-satellite.enable = lib.mkEnableOption "xwayland-satellite" // {
    default = config.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xwayland-satellite ];
    nixpkgs.overlays = [ inputs.xwayland-satellite.overlays.default ];
  };
}
