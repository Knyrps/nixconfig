{ osConfig, config, lib, ... }:

let
  cfg = config.features.fuzzel;
in
{
  options.features.fuzzel.enable = lib.mkEnableOption "fuzzel" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel.enable = true;
  };
}
