{ config, lib, pkgs, ... }:

let
  cfg = config.features.proton-pass-cli;
in
{
  options.features.proton-pass-cli.enable = lib.mkEnableOption "proton-pass-cli" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    # kernel keyring is per-session
    home.packages = [
      (pkgs.proton-pass-cli.overrideAttrs (old: {
        postFixup = old.postFixup + ''
          wrapProgram $out/bin/pass-cli --set PROTON_PASS_LINUX_KEYRING dbus
        '';
      }))
    ];
  };
}
