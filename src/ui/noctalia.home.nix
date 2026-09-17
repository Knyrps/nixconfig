{ osConfig, lib, ... }:

lib.mkIf osConfig.features.noctalia.enable {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings.shell.screenshot = {
      annotate = true;
      directory = "~/Pictures/Screenshots";
      filename_pattern = "Screenshot__%Y-%m-%d_%H-%M-%S.png";
    };
  };
}
