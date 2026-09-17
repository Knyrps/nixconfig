{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.remoting;
  has = osConfig.host.has;
in
{
  options.features.remoting.enable = lib.mkEnableOption "remoting" // {
    default = has "ui" && has "work";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (symlinkJoin {
        name = "freerdp";
        paths = [ freerdp ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/sdl-freerdp --set SDL_VIDEODRIVER wayland
        '';
      })
    ];
  };
}
