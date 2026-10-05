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
    fonts = {
      packages = with pkgs; [
        inter
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];
      fontconfig.defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
