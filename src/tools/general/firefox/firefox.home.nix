{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.firefox;
  has = osConfig.host.has;
  addons = pkgs.nur.repos.rycee.firefox-addons;
  volume-master = addons.buildFirefoxXpiAddon {
    pname = "volume-master";
    version = "1.0.1";
    addonId = "volume_master@outlook.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4732900/volume_master_up-1.0.1.xpi";
    sha256 = "sha256-F6/TeRS7T8FtVDQV26x3n1P55ZsvoUP7AadwFnAhS/g=";
    meta = { };
  };
  common = with addons; [ ublock-origin ipvfoo volume-master pywalfox ];

  xpi = { pname, version, addonId, url, sha256 }:
    addons.buildFirefoxXpiAddon { inherit pname version addonId url sha256; meta = { }; };

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

  substital = xpi {
    pname = "substital";
    version = "2.10.6";
    addonId = "jid1-Cn7LiNrWh4k6RA@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4771616/substital-2.10.6.xpi";
    sha256 = "sha256-aL9sGHkCqzRtnXPPW1vUOQYqT9QKCAZKE1N6yxwmoTM=";
  };

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
    substital
  ];

  keybindings = pkgs.writeText "firefox-keybindings.cfg" ''
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
            el.removeAttribute("data-l10n-id");
            el.setAttribute("key", swap[i][1]);
            keyset = el.parentNode;
          }
          keyset.parentNode.appendChild(keyset);
        } catch (e) {
          Components.utils.reportError(e);
        }
      }

      Services.obs.addObserver(rebind, "browser-delayed-startup-finished");
    })();
  '';

  # reset stale addon cache, re-push theme
  prelaunch = pkgs.writeShellScript "firefox-prelaunch" ''
    root="''${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/mozilla/firefox"
    for dir in "$root"/*/; do
      dir=''${dir%/}
      [ -d "$dir/extensions" ] || continue
      if [ -L "$dir/lock" ]; then
        pid=$(readlink "$dir/lock"); pid=''${pid##*+}
        kill -0 "$pid" 2>/dev/null && continue
      fi
      stamp=$(readlink -f "$dir"/extensions/*.xpi | sort | ${pkgs.coreutils}/bin/sha256sum)
      [ "$stamp" = "$(cat "$dir/.hm-extensions-stamp" 2>/dev/null)" ] && continue
      rm -f "$dir/addonStartup.json.lz4" "$dir/extensions.json"
      rm -rf "$cache/''${dir##*/}/startupCache"
      printf '%s\n' "$stamp" > "$dir/.hm-extensions-stamp"
    done

    if command -v noctalia >/dev/null; then
      ${pkgs.util-linux}/bin/setsid -f sh -c '
        for i in $(seq 60); do
          ${pkgs.procps}/bin/pgrep -u "$(id -u)" -f native-messaging-hosts/pywalfox.json >/dev/null && break
          sleep 1
        done
        sleep 1
        noctalia firefox-theme update
      ' >/dev/null 2>&1
    fi
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
      package = (pkgs.firefox.override { extraPrefsFiles = [ keybindings ]; }).overrideAttrs (old: {
        makeWrapperArgs = old.makeWrapperArgs ++ [ "--run" "${prelaunch}" ];
      });

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

        ExtensionSettings = { "*".installation_mode = "blocked"; } // config.lib.firefox.allow (common ++ private);
      };

      profiles.default = {
        id = 0;
        isDefault = true;
        path = "56h1f58e.default";
        settings = config.lib.firefox.sharedSettings // {
          "browser.startup.homepage" = "https://kagi.com";
          "browser.startup.page" = 1;
        };
        search = {
          force = true;
          default = "kagi";
          privateDefault = "kagi";
          engines = config.lib.firefox.searchEngines;
        };
        extensions = {
          force = true;
          packages = common ++ private;
        };
      };
    };
  };
}
