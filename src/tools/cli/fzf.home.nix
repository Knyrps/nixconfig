{ config, lib, pkgs, ... }:

let
  cfg = config.features.fzf;
in
{
  options.features.fzf.enable = lib.mkEnableOption "fzf" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fzf ];
  };
}
