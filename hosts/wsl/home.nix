{ ... }:

{
  wayland.windowManager.niri.settings._children = [
    { spawn-at-startup._args = [ "noctalia" ]; }
  ];
}
