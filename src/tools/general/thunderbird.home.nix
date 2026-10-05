{ osConfig, config, lib, ... }:

let
  cfg = config.features.thunderbird;
  has = osConfig.host.has;
in
{
  options.features.thunderbird = {
    enable = lib.mkEnableOption "thunderbird" // {
      default = has "ui" && has "personal" && cfg.address != null;
    };

    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "someone@web.de";
      description = ''
        web.de address to configure. Null keeps the module off, so the address
        is set per host instead of living here.
      '';
    };

    realName = lib.mkOption {
      type = lib.types.str;
      default = "knyrps";
      description = "Display name on outgoing mail.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
    };

    accounts.email.accounts.web = {
      primary = true;
      address = cfg.address;
      realName = cfg.realName;

      # full address as login
      userName = cfg.address;

      # enable pop3/imap in web.de first
      imap = {
        host = "imap.web.de";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "smtp.web.de";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };

      # password kept by thunderbird
      thunderbird.enable = true;
    };
  };
}
