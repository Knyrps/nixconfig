{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.zed;
  has = osConfig.host.has;

  prettier = {
    formatter.external = {
      command = lib.getExe pkgs.prettier;
      arguments = [ "--stdin-filepath" "{buffer_path}" ];
    };
    format_on_save = "on";
  };
in
{
  options.features.zed.enable = lib.mkEnableOption "zed" // {
    default = has "ui" && has "coding";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      extensions = [
        # current
        "nix" "lua" "luau"
        # frontend (TS/JS/TSX/CSS/JSON/YAML/Markdown are built in)
        "html" "scss" "vue" "angular"
        # backend / Sitecore
        "csharp" "xml" "sql" "powershell"
        # tooling / CI
        "dockerfile" "toml" "make" "env" "git-firefly"
      ];

      extraPackages = with pkgs; [
        nil nixd
        lua-language-server
        luau luau-lsp
        nodejs                 # runtime for npm-based servers (TS, Vue, Angular, HTML, CSS, YAML) and prettier
        prettier
        omnisharp-roslyn       # native binary — Zed's auto-download won't run on NixOS
      ];

      userSettings = {
        # Point Zed at Nix's node so it stops trying to download its own
        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };

        lsp = {
          lua-language-server.binary.path = lib.getExe pkgs.lua-language-server;
          luau-lsp.binary = {
            path = lib.getExe pkgs.luau-lsp;
            arguments = [ "lsp" ];
          };
          omnisharp.binary = {
            path = lib.getExe pkgs.omnisharp-roslyn;
            arguments = [ "-lsp" ];
          };
        };

        languages = lib.genAttrs [
          "JavaScript" "TypeScript" "TSX"
          "Vue.js" "HTML" "CSS" "SCSS"
          "JSON" "JSONC" "YAML" "Markdown"
        ] (_: prettier);
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "zed" ''
        exec ${config.programs.zed-editor.package}/bin/zeditor --add "$@"
      '')
    ];
  };
}
