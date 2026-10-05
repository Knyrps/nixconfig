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
  celluloid = [ "io.github.celluloid_player.Celluloid.desktop" ];
  writer = [ "writer.desktop" ];
  calc = [ "calc.desktop" ];
  impress = [ "impress.desktop" ];
  draw = [ "draw.desktop" ];
  images = [ "image/png" "image/jpeg" "image/gif" "image/webp" "image/svg+xml" "image/bmp" "image/tiff" "image/avif" "image/heif" ];
  archives = [ "application/zip" "application/x-tar" "application/gzip" "application/x-xz" "application/zstd" "application/x-7z-compressed" "application/vnd.rar" "application/x-bzip2" ];
  text = [ "text/plain" "text/markdown" "text/csv" "text/css" "text/javascript" "text/x-nix" "text/x-python" "text/x-shellscript" "application/json" "application/x-yaml" "application/toml" "application/xml" "application/x-shellscript" ];
  video = [ "video/mp4" "video/x-matroska" "video/webm" "video/x-msvideo" "video/quicktime" "video/mpeg" "video/x-flv" "video/ogg" "video/3gpp" ];
  audio = [ "audio/mpeg" "audio/flac" "audio/ogg" "audio/x-wav" "audio/wav" "audio/aac" "audio/mp4" "audio/x-m4a" "audio/opus" "audio/webm" "audio/x-vorbis+ogg" ];
  documents = [ "application/msword" "application/vnd.openxmlformats-officedocument.wordprocessingml.document" "application/vnd.oasis.opendocument.text" "application/rtf" "text/rtf" ];
  sheets = [ "application/vnd.ms-excel" "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" "application/vnd.oasis.opendocument.spreadsheet" ];
  slides = [ "application/vnd.ms-powerpoint" "application/vnd.openxmlformats-officedocument.presentationml.presentation" "application/vnd.oasis.opendocument.presentation" ];
  mail = [ "x-scheme-handler/mailto" "message/rfc822" "text/calendar" "x-scheme-handler/net.thunderbird" ];
  drawings = [ "application/vnd.oasis.opendocument.graphics" "application/vnd.visio" ];
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
      // lib.optionalAttrs config.features.celluloid.enable (lib.genAttrs (video ++ audio) (_: celluloid))
      // lib.optionalAttrs config.features.libreoffice.enable (lib.genAttrs documents (_: writer) // lib.genAttrs sheets (_: calc) // lib.genAttrs slides (_: impress) // lib.genAttrs drawings (_: draw))
      // lib.optionalAttrs config.features.zed.enable (lib.genAttrs text (_: zed))
      // lib.optionalAttrs config.features.thunderbird.enable (lib.genAttrs mail (_: thunderbird));
    };
  };
}
