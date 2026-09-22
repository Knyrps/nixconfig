{ osConfig, config, lib, ... }:

lib.mkIf osConfig.features.noctalia.enable {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      # per-output geometry can no longer be persisted, see settings.toml below
      lockscreen_widgets.enabled = false;

      plugins = {
        enabled = [ "knyrps/nix-search" ];
        source = [
          { name = "official"; kind = "git"; location = "https://github.com/noctalia-dev/official-plugins"; }
          { name = "community"; kind = "git"; location = "https://github.com/noctalia-dev/community-plugins"; }
          # { name = "dev"; kind = "path"; location = "/home/knyrps/code/noctalia/local-plugins/"; }
        ];
      };

      shell.screenshot = {
        annotate = true;
        directory = "~/Pictures/Screenshots";
        filename_pattern = "Screenshot__%Y-%m-%d_%H-%M-%S.png";
      };

      theme = {
        source = "builtin";
        builtin = "Noctalia";
        mode = "dark";
      };

      wallpaper.default.path = "${config.programs.noctalia.package}/share/noctalia/assets/noctalia-wallpaper.png";
    };
  };

  # noctalia's state layer outranks ~/.config/noctalia, so gui and `noctalia msg`
  # changes would silently shadow everything above. an empty store symlink makes
  # it unwritable: noctalia logs one warning per attempt and keeps the declared
  # value. previous contents land in settings.toml.hm-bak on the first switch.
  xdg.stateFile."noctalia/settings.toml".text = "";
}
