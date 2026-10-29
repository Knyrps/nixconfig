{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.features.musescore;
  has = osConfig.host.has;
in
{
  options.features.musescore.enable = lib.mkEnableOption "musescore" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      # unity build breaks with qt 6.12 qmlcachegen (ambiguous `Type`)
      (pkgs.musescore.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [ "-DMUSE_COMPILE_USE_UNITY:BOOL=OFF" ];
      }))
    ];
  };
}
