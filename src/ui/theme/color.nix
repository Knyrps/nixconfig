{ lib, pkgs }:

let
  digits = lib.stringToCharacters "0123456789abcdef";
  digit = c: lib.lists.findFirstIndex (d: d == c) 0 digits;
  parseHex = s: lib.foldl (acc: c: acc * 16 + digit c) 0 (lib.stringToCharacters (lib.toLower s));
  hex2 = n: let s = lib.toLower (lib.toHexString n); in if builtins.stringLength s < 2 then "0${s}" else s;
  clamp = n: if n < 0 then 0 else if n > 255 then 255 else n;
  round = x: builtins.floor (x + 0.5);
in
rec {
  strip = c: lib.removePrefix "#" c;

  rgb = c:
    let h = strip c; in {
      r = parseHex (builtins.substring 0 2 h);
      g = parseHex (builtins.substring 2 2 h);
      b = parseHex (builtins.substring 4 2 h);
    };

  toHex = { r, g, b }: "#${hex2 (clamp r)}${hex2 (clamp g)}${hex2 (clamp b)}";

  withAlpha = c: a: "${toHex (rgb c)}${hex2 (round (a * 255))}";

  mix = a: b: t:
    let
      A = rgb a;
      B = rgb b;
      m = x: y: round (x * (1 - t) + y * t);
    in toHex { r = m A.r B.r; g = m A.g B.g; b = m A.b B.b; };

  darken = c: t: mix c "#000000" t;
  lighten = c: t: mix c "#ffffff" t;

  base16 = p: with p; {
    base00 = surface;
    base01 = surface_variant;
    base02 = hover;
    base03 = outline;
    base04 = on_surface_variant;
    base05 = on_surface;
    base06 = on_hover;
    base07 = terminal.bright.white;
    base08 = terminal.normal.red;
    base09 = primary;
    base0A = terminal.normal.yellow;
    base0B = terminal.normal.green;
    base0C = terminal.normal.cyan;
    base0D = terminal.normal.blue;
    base0E = terminal.normal.magenta;
    base0F = error;
  };

  noctalia = p: {
    mPrimary = p.primary;
    mOnPrimary = p.on_primary;
    mSecondary = p.secondary;
    mOnSecondary = p.on_secondary;
    mTertiary = p.tertiary;
    mOnTertiary = p.on_tertiary;
    mError = p.error;
    mOnError = p.on_error;
    mSurface = p.surface;
    mOnSurface = p.on_surface;
    mSurfaceVariant = p.surface_variant;
    mOnSurfaceVariant = p.on_surface_variant;
    mOutline = p.outline;
    mShadow = p.shadow;
    mHover = p.hover;
    mOnHover = p.on_hover;
    terminal = {
      inherit (p.terminal) background foreground cursor normal bright;
      cursorText = p.terminal.cursor_text;
      selectionBg = p.terminal.selection_bg;
      selectionFg = p.terminal.selection_fg;
    };
  };

  recolor = table:
    let
      ks = builtins.attrNames table;
      vs = builtins.attrValues table;
      from = ks ++ map lib.toUpper ks;
      to = vs ++ vs;
      go = v:
        if lib.isString v then lib.replaceStrings from to v
        else if lib.isList v then map go v
        else if lib.isAttrs v then lib.mapAttrs (_: go) v
        else v;
    in go;

  fromJsonFile = p: builtins.fromJSON (builtins.readFile p);

  fromJsoncFile = p: builtins.fromJSON (builtins.readFile (
    pkgs.runCommand "${baseNameOf (toString p)}.json" { nativeBuildInputs = [ pkgs.jsonnet ]; }
      "jsonnet ${p} > $out"
  ));
}
