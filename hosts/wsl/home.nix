{ config, ... }:

{
  programs.niri.settings = {
    spawn-at-startup = [ { argv = [ "noctalia" ]; } ];
    binds."Ctrl+Alt+Space".action =
      config.lib.niri.actions.spawn "noctalia" "msg" "panel-toggle" "launcher";
  };
}
