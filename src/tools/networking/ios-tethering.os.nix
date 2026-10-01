{ config, lib, pkgs, ... }:

let
  cfg = config.features.ios-tethering;
  has = config.host.has;
in
{
  options.features.ios-tethering.enable = lib.mkEnableOption "iphone usb tethering" // {
    default = has "laptop";
  };

  config = lib.mkIf cfg.enable {
    # ipheth (in-tree) gives the network interface, but the phone only routes
    # traffic over it once the host holds a trust pairing, which usbmuxd does.
    # its module also lands the udev rule putting apple devices in the usbmux
    # group.
    services.usbmuxd.enable = true;

    # idevicepair, for when the trust prompt does not show up on its own
    environment.systemPackages = [ pkgs.libimobiledevice ];
  };
}
