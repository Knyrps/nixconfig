{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.kitty;
  has = osConfig.host.has;
in
{
  options.features.kitty.enable = lib.mkEnableOption "kitty" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty.enable = true;
    home.packages = [ pkgs.alacritty ];
  };
}
