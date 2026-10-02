{ ... }:

{
  wayland.windowManager.niri.settings._children = [
    {
      # 1920x1200 is forced into the mode list via the video= kernel param in
      # configuration.nix; the panel itself only advertises 3072x1920.
      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1200";
        scale = 1.0;
        position._props = { x = 0; y = 0; };
      };
    }
  ];
}
