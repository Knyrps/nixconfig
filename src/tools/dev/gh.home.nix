{ osConfig, config, lib, ... }:

let
  cfg = config.features.gh;
  has = osConfig.host.has;
in
{
  options.features.gh.enable = lib.mkEnableOption "gh" // {
    default = has "coding";
  };

  config = lib.mkIf cfg.enable {
    programs.gh.enable = true;
  };
}
