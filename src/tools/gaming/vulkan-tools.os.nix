{ config, lib, pkgs, ... }:

let
  cfg = config.features.vulkan-tools;
in
{
  options.features.vulkan-tools.enable = lib.mkEnableOption "vulkan-tools" // {
    default = config.features.steam.enable;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vulkan-tools ];
  };
}
