{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.smartgit;
  has = osConfig.host.has;
in
{
  options.features.smartgit.enable = lib.mkEnableOption "smartgit" // {
    default = has "ui" && has "coding";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.smartgit.overrideAttrs (old: {
        src = old.src.overrideAttrs (_: {
          outputHash = "sha256-2KjUNabcN56cIBORN++YZlx2JuiuN/JMEDVjHo0wqw8=";
        });
      }))
    ];
  };
}
