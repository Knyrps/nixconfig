{ osConfig, config, lib, pkgs, inputs, ... }:

let
  cfg = config.features.spotify;
  has = osConfig.host.has;
  p = osConfig.theme.palette.dark;
  s = osConfig.theme.lib.strip;
  spice = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.features.spotify.enable = lib.mkEnableOption "spotify" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      wayland = true;
      theme = spice.themes.comfy;
      enabledSnippets = [ (builtins.readFile ./spotify.css) ];
      customColorScheme = {
        text = s p.on_surface;
        subtext = s p.on_surface_variant;
        main = s p.surface;
        main-elevated = s p.surface_variant;
        highlight = s p.hover;
        highlight-elevated = s p.hover;
        sidebar = s p.surface;
        player = s p.surface;
        card = s p.surface_variant;
        shadow = s p.shadow;
        selected-row = s p.on_hover;
        button = s p.primary;
        button-active = s p.primary;
        button-disabled = s p.outline;
        tab-active = s p.surface_variant;
        notification = s p.secondary;
        notification-error = s p.error;
        equalizer = s p.primary;
        misc = s p.outline;
        # comfy-only keys; without them the playbar fill is invisible until hovered
        progress-fg = s p.primary;
        progress-bg = s p.outline;
      };
    };
  };
}
