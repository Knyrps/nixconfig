{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    consoleLogLevel = 3;

    # Bottom-row modifiers in Windows order.
    # swap_opt_cmd:      ctrl | opt | cmd  -> ctrl | super | alt
    # swap_fn_leftctrl:  fn | ctrl | ...   -> ctrl | fn | ...
    kernelParams = [
      "hid_apple.swap_opt_cmd=1"
      "hid_apple.swap_fn_leftctrl=1"
    ];
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/1555d1aa-aa09-487a-9ed3-81c587fd9d53";
    randomEncryption.enable = true;
  }];

  hardware = {
    firmware = [
      (pkgs.stdenvNoCC.mkDerivation (final: {
        name = "brcm-firmware";
        src = ./firmware/brcm;
        installPhase = ''
          mkdir -p $out/lib/firmware/brcm
          cp ${final.src}/* $out/lib/firmware/brcm/
        '';
      }))
    ];

    # Left at the default (false). Setting it true writes
    # "options apple-gmux force_igd=y", which muxes the internal panel to the
    # UHD 630 -- amdgpu then cannot reach the panel's DDC lines to read its
    # EDID, so the Navi 14 sits idle while the iGPU struggles with 3072x1920.
    # apple-t2.enableIGPU = true;
  };

  # appletbdrm intermittently times out probing the Touch Bar display at boot
  # ("Failed to get display information", -110), leaving the 05ac:8302 interface
  # unbound. No DRM card then means no /dev/tiny_dfr_display, and tiny-dfr
  # BindsTo that device, so the row stays dark for the whole session.
  #
  # Re-binding the interface does NOT help: the bind re-runs the same probe and
  # times out again. Cycling the device's USB configuration does -- it is the
  # same 0 -> 2 transition the tiny-dfr udev rule performs at enumeration, and
  # it re-initialises the display controller so the next probe succeeds.
  systemd.services.appletbdrm-rebind = {
    description = "Reset the Touch Bar display when appletbdrm times out probing it";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udevd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "appletbdrm-rebind" ''
        drv=/sys/bus/usb/drivers/appletbdrm

        bound() { find "$drv" -maxdepth 1 -name '*:*' 2>/dev/null | grep -q .; }

        # the Touch Bar display, found by id so a shifting bus number cannot
        # point this at the keyboard (1-5) or the touch bar backlight (1-7)
        dev=""
        for attempt in 1 2 3 4 5; do
          for d in /sys/bus/usb/devices/*; do
            case "$(basename "$d")" in *:*) continue;; esac
            [ "$(cat "$d/idVendor" 2>/dev/null)" = "05ac" ] || continue
            [ "$(cat "$d/idProduct" 2>/dev/null)" = "8302" ] || continue
            dev="$d"; break
          done
          [ -n "$dev" ] && break
          sleep 2
        done
        [ -n "$dev" ] || exit 0

        bound && exit 0

        for attempt in 1 2 3; do
          echo 0 > "$dev/bConfigurationValue" 2>/dev/null || true
          sleep 2
          echo 2 > "$dev/bConfigurationValue" 2>/dev/null || true
          sleep 3
          if bound; then
            systemctl --no-block start tiny-dfr.service || true
            exit 0
          fi
        done
        exit 0
      '';
    };
  };

  # Drives the Touch Bar function row (tiny-dfr). Its brightness keys emit the
  # same XF86MonBrightness* events the binds above handle, so the row, the OSD
  # and gmux_backlight all stay on one value.
  hardware.apple.touchBar.enable = true;

  services.t2fanrd = {
    enable = true;
    config = {
      Fan1 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
      Fan2 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
    };
  };

  host.roles = [ "ui" "ssh" "laptop" "bluetooth" "networkmanager" "coding" "personal" ];

  features.ssh.unsafe = true;

  system.stateVersion = "26.05";
}
