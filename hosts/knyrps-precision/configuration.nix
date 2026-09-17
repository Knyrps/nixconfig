{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d".device = "/dev/disk/by-uuid/81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d";

  host.roles = [ "ui" "laptop" "ssh" "bluetooth" "networkmanager" "personal" "work" "coding" "gaming" ];

  features.ssh.unsafe = true;

  system.stateVersion = "26.05";
}
