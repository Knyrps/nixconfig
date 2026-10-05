{ osConfig, config, lib, ... }:

let
  cfg = config.features.mime;
  has = osConfig.host.has;
  firefox = [ "firefox.desktop" ];
  loupe = [ "org.gnome.Loupe.desktop" ];
  nautilus = [ "org.gnome.Nautilus.desktop" ];
  fileRoller = [ "org.gnome.FileRoller.desktop" ];
  zed = [ "dev.zed.Zed.desktop" ];
  thunderbird = [ "thunderbird.desktop" ];
  images = [ "image/png" "image/jpeg" "image/gif" "image/webp" "image/svg+xml" "image/bmp" "image/tiff" "image/avif" "image/heif" ];
  archives = [ "application/zip" "application/x-tar" "application/gzip" "application/x-xz" "application/zstd" "application/x-7z-compressed" "application/vnd.rar" "application/x-bzip2" ];
  text = [ "text/plain" "text/markdown" "text/csv" "text/css" "text/javascript" "text/x-nix" "text/x-python" "text/x-shellscript" "application/json" "application/x-yaml" "application/toml" "application/xml" "application/x-shellscript" ];
in
{
  options.features.mime.enable = lib.mkEnableOption "default applications" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = firefox;
        "application/xhtml+xml" = firefox;
        "application/pdf" = firefox;
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/about" = firefox;
        "x-scheme-handler/unknown" = firefox;
        "inode/directory" = nautilus;
      }
      // lib.genAttrs images (_: loupe)
      // lib.genAttrs archives (_: fileRoller)
      // lib.optionalAttrs config.features.zed.enable (lib.genAttrs text (_: zed))
      // lib.optionalAttrs config.features.thunderbird.enable { "x-scheme-handler/mailto" = thunderbird; };
    };
  };
}
