{ config, lib, ... }:

let
  cfg = config.features.nh;
in
{
  options.features.nh.enable = lib.mkEnableOption "nh" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.nh.enable = true;
  };
}
