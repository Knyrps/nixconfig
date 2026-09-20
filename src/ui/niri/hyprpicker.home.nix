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
      (pkgs.writeShellScriptBin "pick-color" ''
        color=$(${lib.getExe pkgs.hyprpicker} --no-fancy --lowercase-hex --format=hex) || exit 0
        [ -n "$color" ] || exit 0
        printf '%s' "$color" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
        ${lib.getExe' pkgs.libnotify "notify-send"} \
          -t 5000 -i color-select-symbolic "Color Picker" "Selected color: $color"
      '')
    ];
  };
}
