{ config, lib, pkgs, ... }:

let
  theme = import ../../../assets/themes/oceanWaves.nix { inherit pkgs; };
  color = import ./color.nix { inherit lib pkgs; };
  mkCursor = import ./cursor.nix { inherit pkgs; };
  attrs = default: lib.mkOption { type = lib.types.attrs; inherit default; };
in
{
  options.theme = {
    name = lib.mkOption { type = lib.types.str; default = theme.name; };
    palette = attrs theme.palette;
    fonts = attrs theme.fonts;
    # colors are palette keys
    cursor = attrs (theme.cursor // {
      package = mkCursor ({ inherit (theme.cursor) name; }
        // lib.mapAttrs (_: key: config.theme.palette.dark.${key}) theme.cursor.colors);
    });
    icons = attrs theme.icons;
    wallpaper = attrs theme.wallpaper;
    base16 = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = color.base16 config.theme.palette.dark;
    };
    lib = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = color;
    };
  };
}
