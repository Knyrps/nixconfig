{ config, lib, pkgs, ... }:

let
  cfg = config.features.proton-pass-cli;
in
{
  options.features.proton-pass-cli.enable = lib.mkEnableOption "proton-pass-cli" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.proton-pass-cli ];
  };
}
