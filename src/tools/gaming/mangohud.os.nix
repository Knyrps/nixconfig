{ config, lib, pkgs, ... }:

let
  cfg = config.features.mangohud;
in
{
  options.features.mangohud.enable = lib.mkEnableOption "mangohud" // {
    default = config.features.steam.enable;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mangohud ];
  };
}
