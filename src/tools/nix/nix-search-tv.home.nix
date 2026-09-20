{ config, lib, pkgs, ... }:

let
  cfg = config.features.nix-search-tv;
in
{
  options.features.nix-search-tv.enable = lib.mkEnableOption "nix-search-tv" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nix-search-tv ];
  };
}
