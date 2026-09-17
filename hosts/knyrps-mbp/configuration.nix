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

    apple-t2.enableIGPU = true;
  };

  services.t2fanrd = {
    enable = true;
    config = {
      Fan1 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
      Fan2 = { low_temp = 50; high_temp = 75; speed_curve = "exponential"; };
    };
  };

  systemd.services.amdgpu-off = {
    description = "Power off the AMD dGPU via vgaswitcheroo";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    before = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "amdgpu-off" ''
        for i in $(seq 1 30); do
          if [ -e /sys/kernel/debug/vgaswitcheroo/switch ]; then
            echo OFF > /sys/kernel/debug/vgaswitcheroo/switch
            exit 0
          fi
          sleep 1
        done
        exit 1
      '';
    };
  };

  host.roles = [ "ui" "laptop" "ssh" "bluetooth" "networkmanager" "personal" "work" "coding" "gaming" ];

  system.stateVersion = "26.05";
}
