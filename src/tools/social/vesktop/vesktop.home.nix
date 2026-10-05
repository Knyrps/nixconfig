{ osConfig, config, lib, ... }:

let
  cfg = config.features.vesktop;
  has = osConfig.host.has;
in
{
  options.features.vesktop.enable = lib.mkEnableOption "vesktop" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
      vencord.settings.enabledThemes = [ "noctalia.theme.css" "window-controls.css" "contrast.css" "accents.css" "quests.css" ];
      vencord.themes = {
        contrast = builtins.readFile ./contrast.css;
        accents = builtins.readFile ./accents.css;
        quests = builtins.readFile ./quests.css;
        window-controls = builtins.readFile ./window-controls.css;
      };
    };
  };
}
