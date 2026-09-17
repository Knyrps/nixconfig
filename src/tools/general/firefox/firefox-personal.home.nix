{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.firefox-personal;
  has = osConfig.host.has;
  fx = config.lib.firefox;
  addons = pkgs.nur.repos.rycee.firefox-addons;

  gifs-for-github = fx.xpi {
    pname = "gifs-for-github";
    version = "26.9.3";
    addonId = "{443bc2e2-8fa9-44ec-828a-fd84c0664f8d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/5001922/gifs_for_github-26.9.3.xpi";
    sha256 = "sha256-dYy83NkjFSMfenAxdMLfRBzrCyqqDR+/ohY0bq5Kveg=";
  };

  aw-watcher-web = fx.xpi {
    pname = "aw-watcher-web";
    version = "0.6.0";
    addonId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
    url = "https://addons.mozilla.org/firefox/downloads/file/5014296/aw_watcher_web-0.6.0.xpi";
    sha256 = "sha256-3Al5u1E6JRxgfuByG4fUydkUpPKsK/Av9rOQVvZahWg=";
  };

  netflix-household-no-more = fx.xpi {
    pname = "netflix-household-no-more";
    version = "2.0";
    addonId = "netflix-household-no-more@yourdomain.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4593495/netflix_household_no_more-2.0.xpi";
    sha256 = "sha256-RlucI8ZyVqb6N/J1MKJz9GXyyOYiyByzgrGxrtlZd8I=";
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
  ];
in
{
  options.features.firefox-personal.enable = lib.mkEnableOption "personal firefox profile" // {
    default = config.features.firefox.enable && has "personal";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      policies.ExtensionSettings = fx.allow private;

      profiles.default = {
        id = 0;
        isDefault = true;
        path = "56h1f58e.default";
        settings = fx.sharedSettings;
        extensions = {
          force = true;
          packages = fx.common ++ private;
        };
      };
    };
  };
}
