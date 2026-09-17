{ osConfig, lib, pkgs, ... }:

lib.mkIf osConfig.features.nautilus.enable {
  home.packages = [ pkgs.nautilus ];
}
