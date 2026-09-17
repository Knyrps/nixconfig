{ osConfig, lib, ... }:

lib.mkIf osConfig.features.audio.enable {
  services.playerctld.enable = true;
}
