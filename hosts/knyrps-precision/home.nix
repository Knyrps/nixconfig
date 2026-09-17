{ inputs, pkgs, ... }:

{
  home.packages = [ pkgs.streamcontroller ];

  xdg.dataFile."StreamController/plugins/DiscordSC".source = inputs.discord-sc;

  wayland.windowManager.niri.settings.input.touch.map-to-output = "DP-2";

  wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "Dell Inc. DELL UP2716D XGFMF5AV510L" ];
        mode = "2560x1440@59.951";
        scale = 1.0;
        position._props = { x = 0; y = 0; };
      };
    }
    {
      output = {
        _args = [ "Dell Inc. DELL UP2716D XGFMF595527L" ];
        mode = "2560x1440@59.951";
        scale = 1.0;
        position._props = { x = 2560; y = 0; };
      };
    }
    {
      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1080@60.000";
        scale = 1.0;
        position._props = { x = 5120; y = 896; };
      };
    }
    {
      output = {
        _args = [ "DP-2" ];
        mode = "1440x960@59.938";
        scale = 1.0;
        position._props = { x = 3176; y = 1440; };
      };
    }
    {
      window-rule = {
        match._props.app-id = "steam_app_594650";
        open-on-output = "Dell Inc. DELL UP2716D XGFMF595527L";
        open-fullscreen = true;
      };
    }
  ];
}
