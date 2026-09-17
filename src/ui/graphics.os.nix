{ config, lib, ... }:

let
  cfg = config.features.graphics;
  has = config.host.has;
in
{
  options.features.graphics.enable = lib.mkEnableOption "graphics" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
