{ config, lib, ... }:

let
  cfg = config.features.fonts;
  has = config.host.has;
  f = config.theme.fonts;
in
{
  options.features.fonts.enable = lib.mkEnableOption "fonts" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = lib.unique (map (x: x.package) (builtins.attrValues f));
      fontconfig.defaultFonts = {
        sansSerif = [ f.sans.name ];
        serif = [ f.serif.name ];
        monospace = [ f.mono.name ];
        emoji = [ f.emoji.name ];
      };
    };
  };
}
