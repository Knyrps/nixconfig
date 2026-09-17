{ osConfig, config, lib, ... }:

let
  cfg = config.features.idle;
  has = osConfig.host.has;
in
{
  options.features.idle.enable = lib.mkEnableOption "idle lock" // {
    default = osConfig.features.niri.enable && has "laptop";
  };

  config = lib.mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 600; command = "swaylock -f"; }
        { timeout = 900; command = "niri msg action power-off-monitors"; }
      ];
      events = {
        before-sleep = "swaylock -f";
        lock = "swaylock -f";
      };
    };
  };
}
