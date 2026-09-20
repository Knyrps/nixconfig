{ config, lib, ... }:

let
  cfg = config.features.nushell;
in
{
  options.features.nushell.enable = lib.mkEnableOption "nushell" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.nushell.enable = true;
  };
}
