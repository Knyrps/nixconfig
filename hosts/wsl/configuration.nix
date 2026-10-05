{ ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "knyrps";
    useWindowsDriver = true;
  };

  host.roles = [ "ui" "coding" "personal" ];

  features = {
    noctalia.greeter = false;
    noctalia.locked = false;
    audio.enable = false;
  };

  environment.sessionVariables = {
    GALLIUM_DRIVER = "d3d12";
    MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  system.stateVersion = "26.05";
}
