{ config, lib, ... }:

let
  cfg = config.features.ausweisapp;
  has = config.host.has;
in
{
  options.features.ausweisapp.enable = lib.mkEnableOption "ausweisapp" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    programs.ausweisapp = { enable = true; openFirewall = true; };
  };
}
