{ config, lib, ... }:

let
  cfg = config.features.atuin;
in
{
  options.features.atuin.enable = lib.mkEnableOption "atuin" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      flags = [ "--disable-ctrl-r" "--disable-up-arrow" ];
      settings.update_check = false;
    };
  };
}
