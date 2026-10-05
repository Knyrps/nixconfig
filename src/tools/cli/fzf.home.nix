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
      historyWidget.command = "";

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

    programs.fish = lib.mkIf config.features.atuin.enable {
      functions.__fzf_atuin_history = ''
        set -l width (math (tput cols) - 24)
        set -l selection (
          atuin history list --human --print0 --format '{exit}'\t'{duration}'\t'{command}' 2>/dev/null \
          | awk -v w=$width 'BEGIN { RS = "\0"; ORS = "\0"; FS = "\t" } { code[NR] = $1; dur[NR] = $2; cmd[NR] = $3 } END { for (i = NR; i > 0; i--) { if (seen[cmd[i]]++) continue; shown = cmd[i]; gsub(/\n/, " \xe2\x8f\x8e ", shown); status = (code[i] == "0") ? "\033[32m\xe2\x9c\x93\033[0m" : "\033[31m\xe2\x9c\x97\033[0m"; print sprintf("%-*s\t %s \t\033[2m%8s\033[0m\t%s", w, shown, status, dur[i], cmd[i]) } }' \
          | fzf --read0 --ansi --no-sort --exact --layout=default --tabstop=1 --delimiter \t --with-nth 1,2,3 --nth 1 --query (commandline -b) --input-label ' History '
        )
        and commandline -r -- (string split -m 3 \t $selection)[4]
        commandline -f repaint
      '';

      interactiveShellInit = lib.mkAfter ''
        bind \cr __fzf_atuin_history
        bind up __fzf_atuin_history
      '';
    };
  };
}
