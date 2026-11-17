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
    # niri-flake defaults to niri-stable (25.08), which predates actions this
    # config uses (e.g. maximize-window-to-edges). Track niri-unstable — it's
    # what ran here before the stable migration and is cached on niri.cachix.org.
    programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
