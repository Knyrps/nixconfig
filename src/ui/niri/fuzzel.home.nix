{ osConfig, config, lib, ... }:

let
  cfg = config.features.fuzzel;
  p = osConfig.theme.palette.dark;
  s = c: "${osConfig.theme.lib.strip c}ff";
in
{
  options.features.fuzzel.enable = lib.mkEnableOption "fuzzel" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main.font = "${osConfig.theme.fonts.sans.name}:size=12";
        colors = {
          background = s p.surface;
          text = s p.on_surface;
          prompt = s p.on_surface_variant;
          placeholder = s p.outline;
          input = s p.on_surface;
          match = s p.primary;
          selection = s p.hover;
          selection-text = s p.on_hover;
          selection-match = s p.primary;
          border = s p.outline;
        };
        border = {
          width = 2;
          radius = 12;
        };
      };
    };
  };
}
