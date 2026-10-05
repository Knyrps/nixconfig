{ osConfig, config, lib, ... }:

lib.mkIf osConfig.features.noctalia.enable {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      # per-output geometry can no longer be persisted, see settings.toml below
      lockscreen_widgets.enabled = false;

      # noctalia ranks type=.raw. above type=.platform., so on this machine it
      # picked appletb_backlight -- the touch bar, max 2 -- as the display
      # backlight, and the bar never tracked the screen. Pin the real panel.
      brightness.backlight_device = "gmux_backlight";

      plugins = {
        enabled = [ "knyrps/nix-search" "lucasoe/proton-pass" ];
        source = [
          { name = "official"; kind = "git"; location = "https://github.com/noctalia-dev/official-plugins"; }
          { name = "community"; kind = "git"; location = "https://github.com/noctalia-dev/community-plugins"; }
          # { name = "dev"; kind = "path"; location = "/home/knyrps/code/noctalia/local-plugins/"; }
        ];
      };

      bar.default = {
        position = "top";
        margin_ends = 0;
        margin_edge = 0;
        radius = 0;
        shadow = false;
        start = [ "workspaces" ];
        center = [ "clock" ];
        end = [ "media" "tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session" ];
      };

      shell.screenshot = {
        annotate = true;
        directory = "~/Pictures/Screenshots";
        filename_pattern = "Screenshot__%Y-%m-%d_%H-%M-%S.png";
      };

      theme = {
        source = "custom";
        custom_palette = "street";
        mode = "dark";
      };

      wallpaper = {
        fill_mode = "center";
        fill_color = "#191919";
        default.path = "${../../../assets/wallpapers/street.png}";
      };
    };
  };

  xdg.configFile."noctalia/palettes/street.json".source = ./street.json;

  # noctalia's state layer outranks ~/.config/noctalia, so gui and `noctalia msg`
  # changes would silently shadow everything above. an empty store symlink makes
  # it unwritable: noctalia logs one warning per attempt and keeps the declared
  # value. previous contents land in settings.toml.hm-bak on the first switch.
  xdg.stateFile."noctalia/settings.toml" = lib.mkIf osConfig.features.noctalia.locked { text = ""; };
}
