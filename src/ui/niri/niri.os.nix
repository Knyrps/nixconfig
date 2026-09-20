{ config, lib, ... }:

let
  cfg = config.features.niri;
in
{
  options.features.niri.enable = lib.mkEnableOption "niri" // {
    default = config.features.graphics.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
