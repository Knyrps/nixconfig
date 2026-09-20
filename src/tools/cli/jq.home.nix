{ config, lib, pkgs, ... }:

let
  cfg = config.features.jq;
in
{
  options.features.jq.enable = lib.mkEnableOption "jq" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.jq ];
  };
}
