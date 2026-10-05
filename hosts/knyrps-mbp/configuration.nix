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

  # touch bar function row
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
