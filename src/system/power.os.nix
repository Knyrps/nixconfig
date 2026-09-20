{ config, lib, ... }:

let
  cfg = config.features.power;
  has = config.host.has;
in
{
  options.features.power.enable = lib.mkEnableOption "power management" // {
    default = has "laptop";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
