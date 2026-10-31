{ osConfig, lib, inputs, ... }:

let
  t = osConfig.theme;
  p = t.palette.dark;
  c = t.lib;
  mix = c.mix;
  # material 3 roles for the Material-Theme skin, derived from the palette
  roles = {
    primary = p.primary;
    surface-tint = p.primary;
    on-primary = p.on_primary;
    primary-container = mix p.surface p.primary 0.3;
    on-primary-container = mix p.on_surface p.primary 0.4;
    inverse-primary = mix p.primary p.surface 0.4;
    secondary = p.secondary;
    on-secondary = p.on_secondary;
    secondary-container = mix p.surface p.secondary 0.25;
    on-secondary-container = mix p.on_surface p.secondary 0.3;
    tertiary = p.tertiary;
    on-tertiary = p.on_tertiary;
    tertiary-container = mix p.surface p.tertiary 0.25;
    on-tertiary-container = mix p.on_surface p.tertiary 0.3;
    error = p.error;
    on-error = p.on_error;
    error-container = mix p.surface p.error 0.3;
    on-error-container = mix p.on_surface p.error 0.3;
    background = p.surface;
    on-background = p.on_surface;
    surface = p.surface;
    on-surface = p.on_surface;
    surface-variant = p.surface_variant;
    on-surface-variant = p.on_surface_variant;
    surface-dim = p.surface;
    surface-bright = p.hover;
    surface-container-lowest = c.darken p.surface 0.25;
    surface-container-low = mix p.surface p.surface_variant 0.5;
    surface-container = p.surface_variant;
    surface-container-high = mix p.surface_variant p.hover 0.5;
    surface-container-highest = p.hover;
    inverse-surface = p.on_surface;
    inverse-on-surface = p.surface;
    outline = p.outline;
    outline-variant = mix p.surface_variant p.outline 0.5;
    shadow = p.shadow;
    scrim = p.shadow;
  };
  vars = lib.concatStrings (lib.mapAttrsToList (n: v: "  --md-sys-color-${n}: ${v} !important;\n") roles);
in
lib.mkIf osConfig.features.steam.enable {
  # quick css loads before the theme, hence !important
  xdg.configFile."millennium/quick.css".text = ''
    :root {
      --custom-accent-color: ${p.primary} !important;
    ${vars}}

    * { font-family: "${t.fonts.sans.name}", sans-serif !important; }
  '';

  home.activation.materialSteamSkin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    skin="$HOME/.steam/steam/millennium/themes/Material-Theme"
    if [ -d "$HOME/.steam/steam/millennium" ] && [ ! -e "$skin" ]; then
      run mkdir -p "$skin"
      run cp -r --no-preserve=mode,ownership ${inputs.material-theme}/. "$skin/"
    fi
  '';
}
