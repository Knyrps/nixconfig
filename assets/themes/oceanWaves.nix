{ pkgs, ... }:

{
  name = "oceanWaves";

  palette = {
    dark = {
      primary = "#e8744a";
      on_primary = "#1a1210";
      secondary = "#7fa384";
      on_secondary = "#0f1a12";
      tertiary = "#9bb9d4";
      on_tertiary = "#101a24";
      error = "#d9566b";
      on_error = "#1c0d10";
      surface = "#141a1c";
      on_surface = "#c8cfc2";
      surface_variant = "#1e2a2c";
      on_surface_variant = "#8fa391";
      outline = "#4a5f58";
      shadow = "#000000";
      hover = "#2a3a3a";
      on_hover = "#d8dfd2";
      terminal = {
        background = "#141a1c";
        foreground = "#c8cfc2";
        cursor = "#e8744a";
        cursor_text = "#141a1c";
        selection_bg = "#2a3a3a";
        selection_fg = "#d8dfd2";
        normal = {
          black = "#1e2a2c";
          red = "#d9566b";
          green = "#7fa384";
          yellow = "#d8b56a";
          blue = "#7a9fc0";
          magenta = "#c48aa8";
          cyan = "#6fa8a0";
          white = "#c8cfc2";
        };
        bright = {
          black = "#4a5f58";
          red = "#e8748a";
          green = "#9fc3a4";
          yellow = "#eacb88";
          blue = "#9bb9d4";
          magenta = "#d8a8c4";
          cyan = "#8fc4bc";
          white = "#e4e9df";
        };
      };
    };

    light = {
      primary = "#c8582f";
      on_primary = "#fbf4ee";
      secondary = "#4f7a58";
      on_secondary = "#f0f5ef";
      tertiary = "#4f7ba0";
      on_tertiary = "#eef3f8";
      error = "#b8384f";
      on_error = "#fbeef0";
      surface = "#e9ede4";
      on_surface = "#1b2426";
      surface_variant = "#d6ddd0";
      on_surface_variant = "#3e4f46";
      outline = "#7a8f82";
      shadow = "#b8c0b4";
      hover = "#d6ddd0";
      on_hover = "#1b2426";
      terminal = {
        background = "#e9ede4";
        foreground = "#1b2426";
        cursor = "#c8582f";
        cursor_text = "#e9ede4";
        selection_bg = "#d6ddd0";
        selection_fg = "#1b2426";
        normal = {
          black = "#1b2426";
          red = "#b8384f";
          green = "#4f7a58";
          yellow = "#a67c2e";
          blue = "#4f7ba0";
          magenta = "#9a5f80";
          cyan = "#3f8078";
          white = "#d6ddd0";
        };
        bright = {
          black = "#3e4f46";
          red = "#d9566b";
          green = "#7fa384";
          yellow = "#d8b56a";
          blue = "#7a9fc0";
          magenta = "#c48aa8";
          cyan = "#6fa8a0";
          white = "#e9ede4";
        };
      };
    };
  };

  fonts = {
    sans = { name = "Inter"; package = pkgs.inter; };
    serif = { name = "Noto Serif"; package = pkgs.noto-fonts; };
    mono = { name = "JetBrainsMono Nerd Font"; package = pkgs.nerd-fonts.jetbrains-mono; };
    emoji = { name = "Noto Color Emoji"; package = pkgs.noto-fonts-color-emoji; };
  };

  cursor = {
    name = "Bibata-oceanWaves";
    size = 18;
    # dark palette keys
    colors = { base = "primary"; outline = "on_surface"; watch = "surface"; };
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme.override { color = "orange"; };
  };

  wallpaper = {
    path = ../wallpapers/street.png;
    fill = "center";
    fill_color = "#191919";
  };
}
