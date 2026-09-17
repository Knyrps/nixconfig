{ config, lib, ... }:

let
  cfg = config.features.nautilus;
  has = config.host.has;
in
{
  options.features.nautilus.enable = lib.mkEnableOption "nautilus" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    services.gnome.sushi.enable = true;
  };
}
