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
    programs.zed-editor.enable = true;

    home.packages = with pkgs; [
      nil
      nixd
      luau
      luau-lsp
      (writeShellScriptBin "zed" ''
        exec ${config.programs.zed-editor.package}/bin/zeditor --add "$@"
      '')
    ];
  };
}
