{ pkgs }:

# bibata recolored from the palette
{ name, base, outline, watch }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "bibata-cursors-${name}";
  inherit (pkgs.bibata-cursors) version src;

  nativeBuildInputs = [ pkgs.clickgen pkgs.librsvg ];

  buildPhase = ''
    runHook preBuild

    # modern links into groups
    find svg -name '*.svg' -exec sed -i \
      -e 's/#00FF00/${base}/Ig' \
      -e 's/#0000FF/${outline}/Ig' \
      -e 's/#FF0000/${watch}/Ig' {} +

    mkdir bitmaps
    find -L svg/modern -name '*.svg' | while read -r f; do
      rsvg-convert -w 256 -h 256 "$f" -o "bitmaps/$(basename "$f" .svg).png"
    done

    ctgen configs/normal/x.build.toml -p x11 -d bitmaps -n '${name}' -c 'Bibata Modern, recolored from the theme palette'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -dm 0755 $out/share/icons
    cp -r themes/* $out/share/icons/
    runHook postInstall
  '';
}
