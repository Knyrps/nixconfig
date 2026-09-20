{ config, lib, ... }:

let
  cfg = config.features.git;
in
{
  options.features.git.enable = lib.mkEnableOption "git" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name = "knyrps";
        email = "knyrps@knyrps.net";
      };
    };
  };
}
