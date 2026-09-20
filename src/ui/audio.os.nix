{ config, lib, ... }:

let
  cfg = config.features.audio;
  has = config.host.has;
in
{
  options.features.audio.enable = lib.mkEnableOption "audio" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
