{ ... }:

{
  wayland.windowManager.niri.settings = {
    _children = [
      { spawn-at-startup._args = [ "noctalia" ]; }
    ];
    binds."Ctrl+Alt+Space".spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ];
  };
}
