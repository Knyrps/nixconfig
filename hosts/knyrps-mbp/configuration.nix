{ pkgs, ... }:

let
  rtcOffsetRestore = pkgs.writeShellScript "rtc-offset-restore" ''
    mkdir -p /run/rtc-offset /var/lib/rtc-offset
    rtc=$(cat /sys/class/rtc/rtc0/since_epoch) || exit 0
    read up _ < /proc/uptime
    echo "$rtc ''${up%.*}" > /run/rtc-offset/ref

    # before 2000 = firmware base, not real time
    [ "$rtc" -lt 946684800 ] || exit 0

    # never go below the last known time
    floor=$(stat -c %Y /var/lib/systemd/timesync/clock 2>/dev/null || echo 0)
    target=0
    [ -s /var/lib/rtc-offset/offset ] && target=$(( rtc + $(cat /var/lib/rtc-offset/offset) ))
    [ "$target" -ge "$floor" ] || target=$floor

    [ "$target" -gt "$(date +%s)" ] && date -s "@$target" > /dev/null
    exit 0
  '';
in
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

    # windows-order modifiers
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

    # no enableIGPU, breaks panel EDID
  };

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

        # by id, bus numbers shift
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

  # firmware resets the rtc to a ~1970 base on every boot (it still ticks), so
  # learn rtc->real offset after ntp sync and apply it when the rtc looks bogus
  systemd.services.rtc-offset-restore = {
    description = "Correct system clock from bogus T2 RTC using learned offset";
    after = [ "dev-rtc0.device" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "rtc-offset";
      RuntimeDirectory = "rtc-offset";
      RuntimeDirectoryPreserve = true;
      ExecStart = rtcOffsetRestore;
    };
  };

  systemd.paths.rtc-offset-save = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathExists = "/run/systemd/timesync/synchronized";
  };

  systemd.services.rtc-offset-save = {
    description = "Learn T2 RTC offset after NTP sync";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "rtc-offset";
      ExecStart = pkgs.writeShellScript "rtc-offset-save" ''
        read rtc up0 < /run/rtc-offset/ref || exit 0
        [ "$rtc" -lt 946684800 ] || exit 0
        read up _ < /proc/uptime
        echo $(( $(date +%s) - (''${up%.*} - up0) - rtc )) > /var/lib/rtc-offset/offset
      '';
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="rtc", KERNEL=="rtc0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="rtc-offset-restore.service"
  '';

  # hibernate resume goes through firmware too
  powerManagement.resumeCommands = "${rtcOffsetRestore}";

  # touch bar function row
  hardware.apple.touchBar.enable = true;

  services.t2fanrd = {
    enable = true;
    config = {
      Fan1 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
      Fan2 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
    };
  };

  # times out activation when the usb ethernet adapter has no link
  systemd.services.NetworkManager-wait-online.enable = false;

  host.roles =[ "ui" "ssh" "laptop" "bluetooth" "networkmanager" "coding" "personal" "work" ];

  features.ssh.unsafe = true;

  system.stateVersion = "26.05";
}
