{ config, lib, pkgs, ... }:

let
  cfg = config.features.firefox-prewarm;
  ff = config.programs.firefox.finalPackage;

  # Runtime closure of Firefox: the hundreds of small shared libs, GI typelibs
  # and gdk-pixbuf loaders whose *cold* random reads off this machine's T2 NVMe
  # (slow for random I/O under Linux) are what make the first post-boot launch
  # take ~3-6s. Reading them sequentially after login warms the page cache so
  # the first interactive launch is already hot. Also helps other GTK apps,
  # which share the lower half of this closure (glib/pango/cairo/gdk-pixbuf).
  closure = pkgs.closureInfo { rootPaths = [ ff ]; };

  prewarm = pkgs.writeShellScript "firefox-prewarm" ''
    exec ${pkgs.util-linux}/bin/ionice -c3 \
      ${pkgs.vmtouch}/bin/vmtouch -tq $(${pkgs.coreutils}/bin/cat ${closure}/store-paths)
  '';
in
{
  options.features.firefox-prewarm.enable =
    lib.mkEnableOption "warm Firefox's store closure into page cache at login" // {
      default = config.features.firefox.enable;
    };

  config = lib.mkIf cfg.enable {
    systemd.user.services.firefox-prewarm = {
      Unit = {
        Description = "Warm Firefox's store closure into page cache";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        # let the login settle first, then read at idle I/O + nice priority so
        # this never competes with anything the user is actually doing.
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 8";
        ExecStart = toString prewarm;
        Nice = 19;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
