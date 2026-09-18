{ config, lib, ... }:

let
  cfg = config.features.nix-ld;
  has = config.host.has;
in
{
  options.features.nix-ld.enable = lib.mkEnableOption "nix-ld" // {
    default = has "coding";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
