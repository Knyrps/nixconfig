{ pkgs, inputs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  # xwayland-satellite fix
  nixpkgs.overlays = [ inputs.xwayland-satellite.overlays.default ];
}
