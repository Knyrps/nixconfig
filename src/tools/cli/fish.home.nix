{ config, lib, ... }:

let
  cfg = config.features.fish;
in
{
  options.features.fish.enable = lib.mkEnableOption "fish" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
  };
}
