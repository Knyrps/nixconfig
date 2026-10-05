{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.davinci-resolve;
  has = osConfig.host.has;

  offload = osConfig.hardware.nvidia.prime.offload.enable or false;

  # stale upstream hash, drop on pin bump
  resolve = pkgs.davinci-resolve.override {
    runCommandLocal = name: env: cmd:
      pkgs.runCommandLocal name
        (env // { outputHash = "sha256-+3SB32EHpH9/0hM3h8CrO6f7V4ZAmxUFh3P8m6QDeO0="; })
        cmd;
  };

  # needs the dGPU
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
    default = has "ui" && has "multimedia";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
