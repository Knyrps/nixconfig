{ config, lib, ... }:

let
  cfg = config.features.oh-my-posh;
in
{
  options.features.oh-my-posh.enable = lib.mkEnableOption "oh-my-posh" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.oh-my-posh = {
      enable = true;
      # kept verbatim rather than round-tripped through settings so the theme
      # stays byte-identical to the one exported from windows
      configFile = ./oh-my-posh.omp.json;
    };
  };
}
