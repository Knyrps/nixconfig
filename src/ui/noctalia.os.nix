{ config, lib, ... }:

let
  cfg = config.features.noctalia;
in
{
  options.features.noctalia.enable = lib.mkEnableOption "noctalia" // {
    default = config.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "de";
    };
  };
}
