{ pkgs, ... }:

{
  home.packages = with pkgs; [ (symlinkJoin {
    name = "freerdp";
    paths = [ pkgs.freerdp ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sdl-freerdp --set SDL_VIDEODRIVER wayland
    '';
  }) remmina ];
}
