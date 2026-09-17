{ config, lib, ... }:

let
  cfg = config.features.networkmanager;
  has = config.host.has;
in
{
  options.features.networkmanager.enable = lib.mkEnableOption "networkmanager" // {
    default = has "networkmanager";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
