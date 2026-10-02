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
