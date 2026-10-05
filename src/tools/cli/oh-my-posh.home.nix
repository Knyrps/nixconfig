{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.oh-my-posh;
  p = osConfig.theme.palette.dark;
  c = osConfig.theme.lib;
  themed = c.recolor {
    "#0077c2" = p.tertiary;
    "#ffffff" = p.on_tertiary;
    "#fffb38" = p.secondary;
    "#011627" = p.on_secondary;
    "#ff9248" = p.primary;
    "#2d3436" = p.on_primary;
    "#ef5350" = p.error;
    "#e91e63" = p.error;
    "#ffeb95" = p.terminal.normal.yellow;
    "#c5e478" = p.terminal.bright.green;
    "#c792ea" = p.terminal.normal.magenta;
    "#303030" = p.surface_variant;
    "#83769c" = p.surface_variant;
    "#565656" = p.hover;
    "#0e0e0e" = p.surface;
    "#00897b" = p.secondary;
    "#21c7c7" = p.primary;
    "#e0f8ff" = p.on_surface;
  } (c.fromJsonFile ./oh-my-posh.omp.json);
in
{
  options.features.oh-my-posh.enable = lib.mkEnableOption "oh-my-posh" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.oh-my-posh = {
      enable = true;
      configFile = pkgs.writeText "${osConfig.theme.name}.omp.json" (builtins.toJSON themed);
    };
  };
}
