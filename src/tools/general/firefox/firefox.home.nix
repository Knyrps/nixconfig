{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.firefox;
  has = osConfig.host.has;
  addons = pkgs.nur.repos.rycee.firefox-addons;
  common = with addons; [ ublock-origin ipvfoo ];
in
{
  options.features.firefox.enable = lib.mkEnableOption "firefox" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    lib.firefox = {
      inherit common;

      xpi = { pname, version, addonId, url, sha256 ? lib.fakeHash }:
        addons.buildFirefoxXpiAddon {
          inherit pname version addonId url sha256;
          meta = { };
        };

      allow = packages:
        lib.genAttrs (map (p: p.addonId) packages) (_: { installation_mode = "allowed"; });

      sharedSettings = {
        "extensions.autoDisableScopes" = 0;
        "identity.fxaccounts.toolbar.enabled" = false;
        "browser.profiles.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
      };
    };

    programs.firefox = {
      enable = true;
      configPath = ".config/mozilla/firefox";

      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        PasswordManagerEnabled = false;
        OfferToSaveLogins = false;
        DisableFormHistory = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        ExtensionSettings = { "*".installation_mode = "blocked"; } // config.lib.firefox.allow common;
      };
    };
  };
}
