{ osConfig, config, lib, ... }:

let
  cfg = config.features.fzf;
  p = osConfig.theme.palette.dark;
in
{
  options.features.fzf.enable = lib.mkEnableOption "fzf" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      colors = {
        bg = p.surface;
        "bg+" = p.hover;
        fg = p.on_surface;
        "fg+" = p.on_hover;
        hl = p.primary;
        "hl+" = p.primary;
        info = p.on_surface_variant;
        prompt = p.primary;
        pointer = p.primary;
        marker = p.secondary;
        spinner = p.tertiary;
        header = p.on_surface_variant;
        border = p.outline;
      };
    };
  };
}
