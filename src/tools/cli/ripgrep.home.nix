{ config, lib, ... }:

let
  cfg = config.features.ripgrep;
in
{
  options.features.ripgrep.enable = lib.mkEnableOption "ripgrep" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.ripgrep.enable = true;
  };
}
