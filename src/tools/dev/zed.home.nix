{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.zed;
  has = osConfig.host.has;

  tabWidth = 4;

  prettierFmt = {
    formatter.external = {
      command = lib.getExe pkgs.prettier;
      arguments = [
        "--stdin-filepath" "{buffer_path}"
        "--tab-width" (toString tabWidth)
      ];
    };
    format_on_save = "on";
  };

  # vtsls needs explicit inlay hints
  tsInlayHints.inlayHints = {
    parameterNames = { enabled = "all"; suppressWhenArgumentMatchesName = true; };
    parameterTypes.enabled = true;
    variableTypes = { enabled = true; suppressWhenTypeMatchesName = true; };
    propertyDeclarationTypes.enabled = true;
    functionLikeReturnTypes.enabled = true;
    enumMemberValues.enabled = true;
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
        # frontend
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
        nodejs                 # for npm-based servers
        prettier
        omnisharp-roslyn       # zed's download fails on nixos
      ];

      userKeymaps = [
        {
          context = "Editor";
          bindings = {
            "ctrl-#" = "editor::ToggleComments";
          };
        }
        {
          context = "Terminal";
          bindings = {
            "ctrl-v" = "terminal::Paste";
          };
        }
        {
          context = "Terminal && selection";
          bindings = {
            "ctrl-c" = "terminal::Copy";
          };
        }
      ];

      userSettings = {
        # match login shell
        terminal.shell.program = lib.getExe pkgs.fish;

        tab_size = tabWidth;
        hard_tabs = false;

        # keep signature help open
        auto_signature_help = true;
        show_signature_help_after_edits = true;

        hover_popover_delay = 150;

        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = false;
          edit_debounce_ms = 700;
          scroll_debounce_ms = 50;
        };

        # use nix's node
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
          vtsls.settings = {
            javascript = tsInlayHints;
            typescript = tsInlayHints;
          };
        };

        languages = lib.genAttrs [
          "JavaScript" "TypeScript" "TSX"
          "Vue.js" "HTML" "CSS" "SCSS"
          "JSON" "JSONC" "YAML" "Markdown"
        ] (_: prettierFmt);
      };
    };

    home.file."${config.xdg.configHome}/zed/snippets".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/zed-snippets";

    home.packages = [
      (pkgs.writeShellScriptBin "zed" ''
        exec ${config.programs.zed-editor.package}/bin/zeditor --add "$@"
      '')
    ];
  };
}
