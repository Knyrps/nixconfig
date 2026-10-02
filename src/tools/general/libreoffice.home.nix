{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.libreoffice;
  has = osConfig.host.has;
in
{
  options.features.libreoffice.enable = lib.mkEnableOption "libreoffice" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    # the libreoffice wrapper picks dictionaries up from share/hunspell and
    # share/hyphen in every profile, so installing them alongside is enough
    home.packages = with pkgs; [
      libreoffice-fresh
      hunspellDicts.de_DE
      hunspellDicts.en_US
      hyphenDicts.de_DE
      hyphenDicts.en_US
    ];
  };
}
