{ config, lib, pkgs, ... }:

let
  cfg = config.features.proton-pass-cli;
in
{
  options.features.proton-pass-cli.enable = lib.mkEnableOption "proton-pass-cli" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    # pass-cli stores its local encryption key in the kernel keyring by default, and
    # those keys are only readable by the session that created them, so a later login
    # (or the noctalia plugin's own session) gets AccessDenied. point it at the d-bus
    # secret service instead, where gnome-keyring holds the key across reboots.
    # wrapping rather than home.sessionVariables so it also applies to pass-cli calls
    # from systemd user services.
    home.packages = [
      (pkgs.proton-pass-cli.overrideAttrs (old: {
        postFixup = old.postFixup + ''
          wrapProgram $out/bin/pass-cli --set PROTON_PASS_LINUX_KEYRING dbus
        '';
      }))
    ];
  };
}
