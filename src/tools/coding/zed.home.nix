{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.zed;
  has = osConfig.host.has;
in
{
  options.features.zed.enable = lib.mkEnableOption "zed" // {
    default = has "ui" && has "coding";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      extensions = [ "nix" "lua" "luau" ];

      extraPackages = with pkgs; [
        nil nixd
        lua-language-server
        luau luau-lsp
      ];

      userSettings.lsp = {
        lua-language-server.binary.path = lib.getExe pkgs.lua-language-server;
        luau-lsp.binary.path            = lib.getExe pkgs.luau-lsp;
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "zed" ''
        exec ${config.programs.zed-editor.package}/bin/zeditor --add "$@"
      '')
    ];
  };
}
