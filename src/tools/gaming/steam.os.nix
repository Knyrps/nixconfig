{ config, lib, pkgs, ... }:

let
  cfg = config.features.steam;
  has = config.host.has;
in
{
  options.features.steam.enable = lib.mkEnableOption "steam" // {
    default = has "ui" && has "gaming";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mangohud vulkan-tools ];

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        (proton-ge-bin.overrideAttrs (old: let
          version = "GE-Proton11-7";
          variants = {
            "x86_64-linux" = {
              toolName = "${version}-x86_64";
              src = fetchzip {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-x86_64.tar.gz";
                hash = "sha256-ftW0vE45v2JsbaYqo/So0ZFfvdtakHX0XEXEE4TdxLk=";
              };
            };
            "aarch64-linux" = {
              toolName = "${version}-aarch64";
              src = fetchzip {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-aarch64.tar.gz";
                hash = "sha256-tyI95zCUQklRVA9YtarD+gBQouMVcJmv7BafNx5CQu8=";
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
