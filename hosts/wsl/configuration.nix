{ ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "knyrps";
    useWindowsDriver = true;
  };

  host.roles = [ "ui" "coding" ];

  features = {
    noctalia.greeter = false;
    noctalia.locked = false;
    audio.enable = false;
  };

  system.stateVersion = "26.05";
}
