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
    # trust pairing, needed for routing
    services.usbmuxd.enable = true;

    # manual pairing
    environment.systemPackages = [ pkgs.libimobiledevice ];
  };
}
