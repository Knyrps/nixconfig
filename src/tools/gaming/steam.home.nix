{ osConfig, lib, inputs, ... }:

lib.mkIf osConfig.features.steam.enable {
  home.activation.materialSteamSkin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    skin="$HOME/.steam/steam/steamui/skins/Material-Theme"
    if [ -d "$HOME/.steam/steam/steamui" ] && [ ! -e "$skin" ]; then
      run mkdir -p "$skin"
      run cp -r --no-preserve=mode,ownership ${inputs.material-theme}/. "$skin/"
    fi
  '';
}
