{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.features.niri;
in
{
  options.features.niri.enable = lib.mkEnableOption "niri" // {
    default = config.features.graphics.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    environment.systemPackages = [ pkgs.xwayland-satellite ];
    nixpkgs.overlays = [ inputs.xwayland-satellite.overlays.default ];
  };
}
