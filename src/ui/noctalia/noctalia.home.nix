{ osConfig, config, lib, ... }:

let
  t = osConfig.theme;
in
lib.mkIf osConfig.features.noctalia.enable {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      # geometry can't persist
      lockscreen_widgets.enabled = false;

      # the panel, not the touch bar
      brightness.backlight_device = "gmux_backlight";

      plugins = {
        enabled = [ "knyrps/nix-search" "lucasoe/proton-pass" ];
        source = [
          { name = "official"; kind = "git"; location = "https://github.com/noctalia-dev/official-plugins"; }
          { name = "community"; kind = "git"; location = "https://github.com/noctalia-dev/community-plugins"; }
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

      shell.font_family = t.fonts.sans.name;

      idle.behavior = {
        lock = { timeout = 600; action = "lock"; enabled = true; };
        "screen-off" = { timeout = 660; action = "screen_off"; enabled = true; };
      };

      shell.screenshot = {
        annotate = true;
        directory = "~/Pictures/Screenshots";
        filename_pattern = "Screenshot__%Y-%m-%d_%H-%M-%S.png";
      };

      theme = {
        source = "custom";
        custom_palette = t.name;
        mode = "dark";
        templates.builtin_ids = [ "gtk3" "gtk4" ];
        templates.community_ids =
          lib.optional config.features.vesktop.enable "discord"
          ++ lib.optional config.features.firefox.enable "pywalfox"
          ++ lib.optional config.features.libreoffice.enable "libreoffice"
          ++ lib.optional config.features.thunderbird.enable "thunderbird"
          ++ lib.optional config.features.prism-launcher.enable "prismlauncher"
          ++ lib.optional osConfig.features.steam.enable "steam"
          ++ lib.optional config.features.claude-code.enable "claude-code";
      };

      wallpaper = {
        fill_mode = t.wallpaper.fill;
        fill_color = t.wallpaper.fill_color;
        default.path = "${t.wallpaper.path}";
      };
    };
  };

  xdg.configFile."noctalia/palettes/${t.name}.json".text = builtins.toJSON (lib.mapAttrs (_: t.lib.noctalia) t.palette);

  # read-only so gui can't shadow nix
  xdg.stateFile."noctalia/settings.toml" = lib.mkIf osConfig.features.noctalia.locked { text = ""; };
}
