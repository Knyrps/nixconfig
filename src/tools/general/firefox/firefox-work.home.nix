{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.firefox-work;
  has = osConfig.host.has;
  fx = config.lib.firefox;
  addons = pkgs.nur.repos.rycee.firefox-addons;

  sitecore-extensions = fx.xpi {
    pname = "sitecore-extensions";
    version = "4.1.0.0";
    addonId = "{5204f051-144e-4004-83e9-644cab0f803e}";
    url = "https://raw.githubusercontent.com/alan-null/sc_ext.firefox/master/xpi/sitecore_extensions-4.1.0.0.xpi";
    sha256 = "sha256-/vsh7wveffvcedzMSlRa+6nUYendN1cb83tLj6jDKl0=";
  };

  work = with addons; [
    onepassword-password-manager
    angular-devtools
    react-devtools
    vue-js-devtools
    web-developer
    tampermonkey
    sitecore-extensions
  ];

  workBrowser = pkgs.writeShellScriptBin "work-browser" ''
    exec ${config.programs.firefox.finalPackage}/bin/firefox -P work --no-remote --name work-browser "$@"
  '';
in
{
  options.features.firefox-work.enable = lib.mkEnableOption "work firefox profile" // {
    default = config.features.firefox.enable && has "work";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      policies.ExtensionSettings = fx.allow work;

      profiles.work = {
        id = 1;
        isDefault = !config.features.firefox-personal.enable;
        settings = fx.sharedSettings // {
          "browser.startup.homepage" = "https://kagi.com";
          "browser.startup.page" = 1;
          "privacy.sanitize.sanitizeOnShutdown" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
        };
        search = {
          force = true;
          default = "google";
          privateDefault = "google";
          engines = fx.searchEngines;
        };
        extensions = {
          force = true;
          packages = fx.common ++ work;
        };
      };
    };

    home.packages = [ workBrowser ];

    xdg.desktopEntries.work-browser = {
      name = "Work Browser";
      exec = "work-browser %U";
      icon = "firefox";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
  };
}
