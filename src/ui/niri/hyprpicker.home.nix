{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.hyprpicker;
in
{
  options.features.hyprpicker.enable = lib.mkEnableOption "hyprpicker" // {
    default = osConfig.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "hyprpicker";
        paths = [ pkgs.hyprpicker ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hyprpicker \
            --prefix PATH : ${lib.makeBinPath [ pkgs.wl-clipboard pkgs.libnotify ]}
        '';
      })
    ];
  };
}
