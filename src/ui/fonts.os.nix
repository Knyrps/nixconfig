{ config, lib, pkgs, ... }:

let
  cfg = config.features.fonts;
  has = config.host.has;
in
{
  options.features.fonts.enable = lib.mkEnableOption "fonts" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
