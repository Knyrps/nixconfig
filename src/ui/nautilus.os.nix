{ config, lib, pkgs, ... }:

let
  cfg = config.features.nautilus;
  has = config.host.has;
in
{
  options.features.nautilus.enable = lib.mkEnableOption "nautilus" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nautilus ];

    # trash and mounts
    services.gvfs.enable = true;

    services.gnome.sushi.enable = true;

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "wezterm";
    };
  };
}
