{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.prism-launcher;
  has = osConfig.host.has;
in
{
  options.features.prism-launcher.enable = lib.mkEnableOption "prism launcher" // {
    default = has "ui" && has "gaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.prismlauncher ];
  };
}
