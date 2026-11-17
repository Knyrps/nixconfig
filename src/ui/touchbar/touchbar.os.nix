{ config, lib, pkgs, inputs, ... }:

# the t2 touch bar, restyled: tiny-dfr fork (~/code/tiny-dfr) that draws an
# animated cel-shaded seascape behind the keys — tide = battery, sun/moon =
# clock, glint while charging, splashes on touch. all colors derive from the
# system theme below, so a palette swap restyles the bar like any other app.
let
  cfg = config.hardware.apple.touchBar;
  p = config.theme.palette.dark;
  c = config.theme.lib;
in
{
  config = lib.mkIf cfg.enable {
    hardware.apple.touchBar = {
      package = pkgs.tiny-dfr.overrideAttrs (_: { src = inputs.tiny-dfr; });

      settings = {
        ShowButtonOutlines = false;
        FontTemplate = "${config.theme.fonts.sans.name}:bold";
        AnimatedBackground = true;
        AnimationFps = 20;
        Scene = {
          Sky = c.darken p.surface 0.35;
          Star = p.outline;
          WaveBack = c.mix p.surface p.surface_variant 0.8;
          WaveMid = c.mix p.surface_variant p.hover 0.8;
          WaveFront = c.mix p.hover p.secondary 0.18;
          Crest = p.terminal.bright.cyan;
          Sun = p.terminal.normal.yellow;
          Moon = p.tertiary;
          Splash = p.primary;
          Glint = p.primary;
          Text = p.on_surface;
          TextActive = p.on_primary;
          ButtonActive = p.primary;
          Scrim = p.surface;
        };
      };
    };
  };
}
