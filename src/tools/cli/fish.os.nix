{ config, lib, pkgs, ... }:

let
  cfg = config.features.fish;
in
{
  options.features.fish.enable = lib.mkEnableOption "fish" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    # needed at system level so vendor completions land and fish is a valid login shell
    programs.fish.enable = true;
    users.users.knyrps.shell = pkgs.fish;
  };
}
