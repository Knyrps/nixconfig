{ config, lib, pkgs, ... }:

let
  cfg = config.features.noctalia;

  # A "no GUI" greeter session: drops straight into a fish login shell on the
  # VT instead of a compositor. Handy for headless / SSH use.
  fishSession = pkgs.writeTextDir "share/wayland-sessions/fish.desktop" ''
    [Desktop Entry]
    Name=Fish (no GUI)
    Comment=Plain fish login shell — no compositor, for headless / SSH use
    Exec=${lib.getExe pkgs.fish} --login --interactive
    Type=Application
  '' // { providedSessions = [ "fish" ]; };
in
{
  options.features.noctalia = {
    enable = lib.mkEnableOption "noctalia" // {
      default = config.features.niri.enable;
    };
    greeter = lib.mkEnableOption "noctalia greeter" // {
      default = true;
    };
    locked = lib.mkEnableOption "declarative settings only" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.greeter) {
    services.displayManager = {
      noctalia-greeter = {
        enable = true;
        settings.keyboard.layout = "de";
      };
      sessionPackages = [ fishSession ];
    };
  };
}
