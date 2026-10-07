{ config, lib, inputs, ... }:

let
  cfg = config.features.repo;
in
{
  options.features.repo.enable = lib.mkEnableOption "repo" // {
    default = config.features.fish.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.fish.plugins = [{
      name = "repo";
      src = inputs.repo;
    }];
  };
}
