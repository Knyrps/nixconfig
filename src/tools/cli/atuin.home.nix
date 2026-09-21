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

      settings = {
        # don't run the command on <enter>, just put it on the line
        enter_accept = false;
        # inline search rather than a fullscreen takeover
        style = "compact";
        inline_height = 15;
      };
    };
  };
}
