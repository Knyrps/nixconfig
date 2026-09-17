{ config, lib, ... }:

let
  cfg = config.features.fwupd;
  has = config.host.has;
in
{
  options.features.fwupd.enable = lib.mkEnableOption "fwupd" // {
    default = has "laptop";
  };

  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
