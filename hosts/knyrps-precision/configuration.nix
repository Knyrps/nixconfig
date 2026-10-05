{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d".device = "/dev/disk/by-uuid/81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d";

  # before snd_hda_intel, else codec is lost
  boot.initrd.kernelModules = [ "i915" ];

  host.roles = [ "ui" "laptop" "ssh" "bluetooth" "networkmanager" "personal" "work" "coding" "gaming" "multimedia" ];

  # stream deck udev rules
  programs.streamcontroller.enable = true;

  features.ssh.unsafe = true;
  features.work-vpn.profile = true;

  system.stateVersion = "26.05";
}
