{ config, lib, ... }:

let
  cfg = config.features.noctalia;
in
{
  options.features.noctalia = {
    enable = lib.mkEnableOption "noctalia" // {
      default = config.features.niri.enable;
    };
    greeter = lib.mkEnableOption "noctalia greeter" // {
      default = true;
    };
    locked = lib.mkEnableOption "declarative settings only" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.greeter) {
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "de";
    };
  };
}
