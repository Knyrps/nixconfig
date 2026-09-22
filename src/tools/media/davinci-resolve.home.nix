{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.davinci-resolve;
  has = osConfig.host.has;

  offload = osConfig.hardware.nvidia.prime.offload.enable or false;

  # Blackmagic re-rolled the 21.1 archive, so the hash our nixpkgs pin carries is
  # stale. This is the corrected value from nixpkgs master; drop the override once
  # the pin catches up. runCommandLocal is only used for the src fetch.
  resolve = pkgs.davinci-resolve.override {
    runCommandLocal = name: env: cmd:
      pkgs.runCommandLocal name
        (env // { outputHash = "sha256-+3SB32EHpH9/0hM3h8CrO6f7V4ZAmxUFh3P8m6QDeO0="; })
        cmd;
  };

  # Resolve needs a CUDA/OpenCL capable GPU, so force it onto the dGPU.
  package =
    if offload then
      pkgs.symlinkJoin {
        name = "davinci-resolve-offload";
        paths = [ resolve ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/davinci-resolve \
            --set __NV_PRIME_RENDER_OFFLOAD 1 \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
            --set __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set __VK_LAYER_NV_optimus NVIDIA_only
        '';
      }
    else
      resolve;
in
{
  options.features.davinci-resolve.enable = lib.mkEnableOption "davinci resolve" // {
    default = has "ui" && has "personal";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
