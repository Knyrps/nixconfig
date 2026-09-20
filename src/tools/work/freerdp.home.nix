{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.freerdp;
  has = osConfig.host.has;
in
{
  options.features.freerdp.enable = lib.mkEnableOption "freerdp" // {
    default = has "ui" && has "work";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "freerdp";
        paths = [ pkgs.freerdp ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/sdl-freerdp --set SDL_VIDEODRIVER wayland
        '';
      })
    ];
  };
}
