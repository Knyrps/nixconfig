{ inputs, ... }:

{
  xdg.dataFile."StreamController/plugins/DiscordSC".source = inputs.discord-sc;

  programs.niri.settings.input.touch.map-to-output = "HP Inc. Slice20 Unknown";

  programs.niri.settings.outputs = {
    "Dell Inc. DELL UP2716D XGFMF5AV510L" = {
      mode = { width = 2560; height = 1440; refresh = 59.951; };
      scale = 1.0;
      position = { x = 0; y = 0; };
    };
    "Dell Inc. DELL UP2716D XGFMF595527L" = {
      mode = { width = 2560; height = 1440; refresh = 59.951; };
      scale = 1.0;
      position = { x = 2560; y = 0; };
    };
    "eDP-1" = {
      mode = { width = 1920; height = 1080; refresh = 60.000; };
      scale = 1.0;
      position = { x = 5120; y = 896; };
    };
    "HP Inc. Slice20 Unknown" = {
      mode = { width = 1440; height = 960; refresh = 59.938; };
      scale = 1.0;
      position = { x = 3176; y = 1440; };
    };
  };

  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "steam_app_594650"; } ];
      open-on-output = "Dell Inc. DELL UP2716D XGFMF595527L";
      open-fullscreen = true;
    }
  ];
}
