{ config, lib, pkgs, ... }:

let
    cfg = config.features.fish;
in
{
  options.features.fish.enable = lib.mkEnableOption "fish" // {
      default = true;
  };

  config = lib.mkIf cfg.enable {
    # login shell, vendor completions
    programs.fish.enable = true;
    users.users.knyrps.shell = pkgs.fish;
  };
}
