{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.kate;
  has = osConfig.host.has;
in
{
  options.features.kate.enable = lib.mkEnableOption "kate" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kdePackages.kate ];
  };
}
