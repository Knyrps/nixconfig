{ config, lib, pkgs, ... }:

let
  cfg = config.features.fastfetch;
in
{
  options.features.fastfetch.enable = lib.mkEnableOption "fastfetch" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fastfetch ];
  };
}
