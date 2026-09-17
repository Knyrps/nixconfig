{ config, lib, ... }:

{
  options.features.audio.enable = lib.mkEnableOption "audio" // {
    default = config.host.has "ui";
  };
}
