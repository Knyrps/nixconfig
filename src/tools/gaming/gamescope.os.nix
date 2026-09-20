{ config, lib, ... }:

let
  cfg = config.features.gamescope;
in
{
  options.features.gamescope.enable = lib.mkEnableOption "gamescope" // {
    default = config.features.steam.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
}
