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

      # web.de authenticates with the full address, not a short login name
      userName = cfg.address;

      # freemail accounts ship with pop3/imap switched off. it has to be
      # enabled under Einstellungen -> POP3/IMAP before any of this connects.
      imap = {
        host = "imap.web.de";
        port = 993;
        tls.enable = true;
      };

      # 465 with implicit tls also works; 587 is what web.de documents
      smtp = {
        host = "smtp.web.de";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };

      # thunderbird keeps the password in its own store, so there is no secret
      # here to keep out of the repo
      thunderbird.enable = true;
    };
  };
}
