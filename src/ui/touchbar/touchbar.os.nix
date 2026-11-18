{ config, lib, pkgs, inputs, ... }:

# the t2 touch bar, restyled: tiny-dfr fork (~/code/tiny-dfr) that draws an
# animated cel-shaded seascape behind the keys — tide = battery, sun/moon =
# clock, glint while charging, splashes on touch. all colors derive from the
# system theme below, so a palette swap restyles the bar like any other app.
let
  cfg = config.hardware.apple.touchBar;
  p = config.theme.palette.dark;
  c = config.theme.lib;
  fkeys = map (n: { Text = "F${toString n}"; Action = "F${toString n}"; }) (lib.range 1 12);
  mediaKeys = [
    { Icon = "brightness_low";  Action = "BrightnessDown"; }
    { Icon = "brightness_high"; Action = "BrightnessUp"; }
    { Icon = "mic_off";         Action = "MicMute"; }
    { Icon = "search";          Action = "Search"; }
    { Icon = "backlight_low";   Action = "IllumDown"; }
    { Icon = "backlight_high";  Action = "IllumUp"; }
    { Icon = "fast_rewind";     Action = "PreviousSong"; }
    { Icon = "play_pause";      Action = "PlayPause"; }
    { Icon = "fast_forward";    Action = "NextSong"; }
    { Icon = "volume_off";      Action = "Mute"; }
    { Icon = "volume_down";     Action = "VolumeDown"; }
    { Icon = "volume_up";       Action = "VolumeUp"; }
  ];
  # 13th key: cycles the scene style, shows a glyph of the current one
  switcher = { Special = "CycleStyle"; };
in
{
  config = lib.mkIf cfg.enable {
    # the daemon (running as nobody) persists the chosen style here
    systemd.tmpfiles.rules = [ "d /var/lib/tiny-dfr 0755 nobody nogroup -" ];

    hardware.apple.touchBar = {
      package = pkgs.tiny-dfr.overrideAttrs (_: { src = inputs.tiny-dfr; });

      settings = {
        ShowButtonOutlines = false;
        FontTemplate = "${config.theme.fonts.sans.name}:bold";
        AnimatedBackground = true;
        AnimationFps = 20;
        Style = "seascape";
        PrimaryLayerKeys = fkeys ++ [ switcher ];
        MediaLayerKeys = mediaKeys ++ [ switcher ];
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
