{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.fzf;
  p = osConfig.theme.palette.dark;
in
{
  options.features.fzf.enable = lib.mkEnableOption "fzf" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ fd bat ];

    programs.fzf = {
      enable = true;

      defaultCommand = "fd --type f --follow";
      fileWidget.command = "fd --type f --follow";
      changeDirWidget.command = "fd --type d --follow";

      defaultOptions = [
        "--ansi"
        "--cycle"
        "--height=~100%"
        "--info=inline-right"
        "--layout=reverse"
        "--preview-window=border-rounded:noinfo"
        "--style=full:rounded"
      ];

      fileWidget.options = [
        "--select-1"
        "--exit-0"
        "--preview='bat --color=always --style=numbers --line-range=:250 {}'"
        "--list-label=' Preview: <Ctrl+P> '"
        "--list-label-pos=bottom"
        "--input-label=' Files '"
        "--bind='start:change-preview-window(hidden)'"
        "--bind='ctrl-p:toggle-preview'"
      ];

      historyWidget.options = [
        "--no-sort"
        "--exact"
      ];

      colors = {
        bg = p.surface;
        "bg+" = p.hover;
        fg = p.on_surface;
        "fg+" = p.on_hover;
        hl = p.primary;
        "hl+" = p.primary;
        info = p.on_surface_variant;
        prompt = p.secondary;
        pointer = p.secondary;
        marker = p.terminal.normal.yellow;
        spinner = p.tertiary;
        header = p.on_surface;
        border = p.outline;
        gutter = p.surface;
        scrollbar = p.secondary;
        list-label = p.on_surface_variant;
      };
    };
  };
}
