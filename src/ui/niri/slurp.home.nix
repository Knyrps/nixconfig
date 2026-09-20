{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.slurp;
in
{
  options.features.slurp.enable = lib.mkEnableOption "slurp" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.slurp ];
  };
}
