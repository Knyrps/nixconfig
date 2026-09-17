{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # huhhh this works lmao
    (symlinkJoin {
      name = "spotify";
      paths = [ pkgs.spotify ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/spotify --add-flags "--ozone-platform=wayland --enable-features=WaylandWindowDecorations"
      '';
    })
    # spotify
  ];
}
