{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.features.nautilus;
  has = osConfig.host.has;
in
{
  options.features.nautilus.enable = lib.mkEnableOption "nautilus" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    # right-click -> Scripts -> Copy Path
    home.file."${config.xdg.dataHome}/nautilus/scripts/Copy Path" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        # nautilus hands us the selection newline-separated; fall back to the
        # folder being viewed when nothing is selected
        paths="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
        if [ -z "$paths" ]; then
          paths="''${NAUTILUS_SCRIPT_CURRENT_URI#file://}"
        fi
        printf '%s' "$paths" | ${lib.getExe' pkgs.gnused "sed"} '/^$/d' | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} -n
      '';
    };
  };
}
