{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.firefox;
  has = osConfig.host.has;
  addons = pkgs.nur.repos.rycee.firefox-addons;
  common = with addons; [ ublock-origin ipvfoo ];

  # Firefox has no pref for keyboard shortcuts, so swap the <key> elements from
  # the autoconfig sandbox once each browser window is up.
  keybindings = pkgs.writeText "firefox-keybindings.cfg" ''
    // Swap Ctrl+Shift+N and Ctrl+Shift+P: private window on N, reopen closed window on P.
    (function () {
      var swap = [
        ["key_privatebrowsing", "N"],
        ["key_undoCloseWindow", "P"],
      ];

      function rebind(win) {
        try {
          var doc = win.document;
          var keyset = null;
          for (var i = 0; i < swap.length; i++) {
            var el = doc.getElementById(swap[i][0]);
            if (!el) return;
            // Drop the Fluent id so localization cannot restore the old key.
            el.removeAttribute("data-l10n-id");
            el.setAttribute("key", swap[i][1]);
            keyset = el.parentNode;
          }
          // Re-inserting the keyset forces XUL to rebuild its shortcut table.
          keyset.parentNode.appendChild(keyset);
        } catch (e) {
          Components.utils.reportError(e);
        }
      }

      Services.obs.addObserver(rebind, "browser-delayed-startup-finished");
    })();
  '';
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
        lib.genAttrs (map (p: p.addonId) packages) (_: {
          installation_mode = "allowed";
          # A per-id entry replaces the "*" entry outright, so this has to be set here.
          private_browsing = true;
        });

      searchEngines = {
        kagi = {
          name = "Kagi";
          urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
          iconMapObj."16" = "https://kagi.com/favicon.ico";
          definedAliases = [ "@k" ];
        };
        bing.metaData.hidden = true;
        ebay.metaData.hidden = true;
        amazondotcom-us.metaData.hidden = true;
      };

      sharedSettings = {
        "extensions.autoDisableScopes" = 0;
        "identity.fxaccounts.toolbar.enabled" = false;
        "browser.profiles.enabled" = false;
        "browser.aboutConfig.showWarning" = false;

        "browser.contentblocking.category" = "strict";
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "dom.private-attribution.submission.enabled" = false;
        "cookiebanners.service.mode" = 1;
        "cookiebanners.service.mode.privateBrowsing" = 1;

        "browser.ml.enable" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.shortcuts" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.chat.page" = false;
        "browser.ml.linkPreview.enabled" = false;
        "browser.ml.pageAssist.enabled" = false;
        "browser.tabs.groups.smart.enabled" = false;
        "pdfjs.enableAltText" = false;
        "pdfjs.enableGuessAltText" = false;
        "browser.shopping.experience2023.enabled" = false;
        "browser.translations.automaticallyPopup" = false;

        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.mdn.featureGate" = false;
        "browser.urlbar.weather.featureGate" = false;
        "browser.urlbar.yelp.featureGate" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;

        "browser.discovery.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.vpn_promo.enabled" = false;
        "browser.promo.focus.enabled" = false;
        "browser.promo.pin.enabled" = false;
        "browser.promo.cookiebanners.enabled" = false;
        "browser.preferences.moreFromMozilla" = false;
      };
    };

    programs.firefox = {
      enable = true;
      configPath = ".config/mozilla/firefox";
      package = pkgs.firefox.override { extraPrefsFiles = [ keybindings ]; };

      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableAppUpdate = true;
        PasswordManagerEnabled = false;
        OfferToSaveLogins = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableFormHistory = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFeedbackCommands = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        NetworkPrediction = false;
        HttpsOnlyMode = "enabled";
        DNSOverHTTPS.Enabled = false;

        EnableTrackingProtection = {
          Value = true;
          Locked = false;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };

        Cookies = {
          Behavior = "reject-tracker-and-partition-foreign";
          BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
        };

        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = false;
        };

        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = false;
        };

        UserMessaging = {
          WhatsNew = false;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          UrlbarInterventions = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          FirefoxLabs = false;
        };

        ExtensionSettings = { "*".installation_mode = "blocked"; } // config.lib.firefox.allow common;
      };
    };
  };
}
