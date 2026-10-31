{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.features.steam;
  has = config.host.has;
in
{
  options.features.steam.enable = lib.mkEnableOption "steam" // {
    default = has "ui" && has "gaming";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.millennium.overlays.default ];

    programs.steam = {
      enable = true;
      package = pkgs.millennium-steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        (proton-ge-bin.overrideAttrs (old: let
          version = "GE-Proton11-11";
          variants = {
            "x86_64-linux" = {
              toolName = "${version}-x86_64";
              src = fetchzip {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-x86_64.tar.gz";
                hash = "sha256-3tVgf83IkteFtVo/bHd4yG1xCtPeuW8FXaTrHOLjvKQ=";
              };
            };
            "aarch64-linux" = {
              toolName = "${version}-aarch64";
              src = fetchzip {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-aarch64.tar.gz";
                hash = "sha256-ev2dO+vZAHmobs0OCLOODGerS3AfZIavWDr7Ftt3dUM=";
              };
            };
          };
        in {
          inherit version;
          src = variants.${stdenvNoCC.hostPlatform.system}.src;
        }))
      ];
    };
  };
}
