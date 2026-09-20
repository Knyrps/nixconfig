{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.claude-code;
  has = osConfig.host.has;
in
{
  options.features.claude-code.enable = lib.mkEnableOption "claude-code" // {
    default = has "coding";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
