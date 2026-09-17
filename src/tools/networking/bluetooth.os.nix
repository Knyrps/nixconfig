{ config, lib, ... }:

let
  cfg = config.features.bluetooth;
  has = config.host.has;
in
{
  options.features.bluetooth.enable = lib.mkEnableOption "bluetooth" // {
    default = has "bluetooth";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
  };
}
