{ osConfig, config, lib, ... }:

let
  cfg = config.features.direnv;
  has = osConfig.host.has;
in
{
  options.features.direnv.enable = lib.mkEnableOption "direnv" // {
    default = has "coding";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
