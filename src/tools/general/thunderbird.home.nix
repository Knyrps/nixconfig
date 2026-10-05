{ osConfig, config, lib, ... }:

let
  cfg = config.features.thunderbird;
  has = osConfig.host.has;
in
{
  options.features.thunderbird.enable = lib.mkEnableOption "thunderbird" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    # accounts set up in the app
    programs.thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
    };
  };
}
