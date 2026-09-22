{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.prism-launcher;
  has = osConfig.host.has;

  offload = osConfig.hardware.nvidia.prime.offload.enable or false;

  # Offload Minecraft (LWJGL) to the iGPU via PRIME offload variables.
  package =
    if offload then
      pkgs.symlinkJoin {
        name = "prismlauncher-offload";
        paths = [ pkgs.prismlauncher ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/prismlauncher \
            --set __NV_PRIME_RENDER_OFFLOAD 1 \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
            --set __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set __VK_LAYER_NV_optimus NVIDIA_only
        '';
      }
    else
      pkgs.prismlauncher;
in
{
  options.features.prism-launcher.enable = lib.mkEnableOption "prism launcher" // {
    default = has "ui" && has "gaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
