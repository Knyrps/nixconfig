{ config, lib, pkgs, ... }:

let
  cfg = config.features.fonts;
in
{
  options.features.fonts.enable = lib.mkEnableOption "fonts" // {
    default = config.host.has "ui";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
