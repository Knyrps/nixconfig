{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.spotify;
  has = osConfig.host.has;
in
{
  options.features.spotify.enable = lib.mkEnableOption "spotify" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "spotify";
        paths = [ pkgs.spotify ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/spotify --add-flags "--ozone-platform=wayland --enable-features=WaylandWindowDecorations"
        '';
      })
    ];
  };
}
