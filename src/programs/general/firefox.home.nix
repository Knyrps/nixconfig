{ pkgs, lib, config, ... }:

let
  addons = pkgs.nur.repos.rycee.firefox-addons;

  xpi = { pname, version, addonId, url, sha256 ? lib.fakeHash }:
    addons.buildFirefoxXpiAddon {
      inherit pname version addonId url sha256;
      meta = { };
    };

  sitecore-extensions = xpi {
    pname = "sitecore-extensions";
    version = "4.1.0.0";
    addonId = "{5204f051-144e-4004-83e9-644cab0f803e}";
    url = "https://raw.githubusercontent.com/alan-null/sc_ext.firefox/master/xpi/sitecore_extensions-4.1.0.0.xpi";
    sha256 = "sha256-/vsh7wveffvcedzMSlRa+6nUYendN1cb83tLj6jDKl0=";
  };

  gifs-for-github = xpi {
    pname = "gifs-for-github";
    version = "26.9.3";
    addonId = "{443bc2e2-8fa9-44ec-828a-fd84c0664f8d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/5001922/gifs_for_github-26.9.3.xpi";
    sha256 = "sha256-dYy83NkjFSMfenAxdMLfRBzrCyqqDR+/ohY0bq5Kveg=";
  };

  aw-watcher-web = xpi {
    pname = "aw-watcher-web";
    version = "0.6.0";
    addonId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
    url = "https://addons.mozilla.org/firefox/downloads/file/5014296/aw_watcher_web-0.6.0.xpi";
    sha256 = "sha256-3Al5u1E6JRxgfuByG4fUydkUpPKsK/Av9rOQVvZahWg=";
  };

  netflix-household-no-more = xpi {
    pname = "netflix-household-no-more";
    version = "2.0";
    addonId = "netflix-household-no-more@yourdomain.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4593495/netflix_household_no_more-2.0.xpi";
    sha256 = "sha256-RlucI8ZyVqb6N/J1MKJz9GXyyOYiyByzgrGxrtlZd8I=";
  };

  common = with addons; [ ublock-origin ipvfoo ];

  work = with addons; [
    onepassword-password-manager
    angular-devtools
    react-devtools
    vue-js-devtools
    web-developer
    tampermonkey
    sitecore-extensions
  ];

  private = with addons; [
    proton-pass
    sponsorblock
    return-youtube-dislikes
    dearrow
    kagi-search
    instagram-video-control
    twitch-auto-points
    youtube-shorts-block
    addons."7tv"
    gifs-for-github
    aw-watcher-web
    netflix-household-no-more
  ];

  sharedSettings = {
    "extensions.autoDisableScopes" = 0;
    "identity.fxaccounts.toolbar.enabled" = false;
    "browser.profiles.enabled" = false;
    "browser.aboutConfig.showWarning" = false;
  };

  workFirefox = config.programs.firefox.finalPackage.override (old: {
    extraPolicies = (old.extraPolicies or { }) // {

    };
  });

  workBrowser = pkgs.writeShellScriptBin "work-browser" ''
    exec ${workFirefox}/bin/firefox -P work --no-remote --name work-browser "$@"
  '';

  allAddons   = common ++ work ++ private;
  declaredIds = map (p: p.addonId) allAddons;
in
{
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
      ExtensionSettings = {
            "*".installation_mode = "blocked";
          } // lib.genAttrs declaredIds (_: { installation_mode = "allowed"; });
    };

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        path = "56h1f58e.default";
        settings = sharedSettings;
        extensions = {
          force = true;
          packages = common ++ private;
        };
      };

      work = {
        id = 1;
        isDefault = false;
        settings = sharedSettings // {
          "browser.startup.homepage" = "https://myapps.microsoft.com";
          "browser.startup.page" = 1;
          "browser.shell.checkDefaultBrowser" = false;
          "privacy.sanitize.sanitizeOnShutdown" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
        };
        extensions = { force = true; packages = common ++ work; };
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
}
