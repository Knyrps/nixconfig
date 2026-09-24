{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d".device = "/dev/disk/by-uuid/81d4d08c-ebe4-4b8a-bd88-c8f664e37a4d";

  # Load i915 early so its audio component is ready before snd_hda_intel probes.
  # Otherwise the ALC289 codec intermittently loses the race and the kernel
  # disables it ("hdaudioC4D0: Unable to configure, disabling"), leaving the
  # internal card with only its HDMI codec and no analog sink or source.
  boot.initrd.kernelModules = [ "i915" ];

  host.roles = [ "ui" "laptop" "ssh" "bluetooth" "networkmanager" "personal" "work" "coding" "gaming" ];

  programs.nh.flake = "~/code/nix";

  features.ssh.unsafe = true;

  system.stateVersion = "26.05";
}
