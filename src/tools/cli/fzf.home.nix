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
      fileWidgetCommand = "fd --type f --follow";
      changeDirWidgetCommand = "fd --type d --follow";

      defaultOptions = [
        "--ansi"
        "--cycle"
        "--height=~100%"
        "--info=inline-right"
        "--layout=reverse"
        "--preview-window=border-rounded:noinfo"
        "--style=full:rounded"
      ];

      fileWidgetOptions = [
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
      # $argv[1] is the fish input function to fall back to when atuin returns
      # nothing -- it exits non-zero on e.g. a db migration mismatch after a
      # nixpkgs bump, and without this the picker would just come up empty.
      functions.__fzf_atuin_history = ''
        set -l fallback $argv[1]
        test -n "$fallback"; or set fallback history-pager

        set -l width (math (tput cols) - 24)
        set -l entries (mktemp)
        atuin history list --human --print0 --format '{exit}'\t'{duration}'\t'{command}' 2>/dev/null \
        | awk -v w=$width 'BEGIN { RS = "\0"; ORS = "\0"; FS = "\t" } $0 == "" { next } { n++; code[n] = $1; dur[n] = $2; cmd[n] = $3 } END { for (i = n; i > 0; i--) { if (seen[cmd[i]]++) continue; shown = cmd[i]; gsub(/\n/, " \xe2\x8f\x8e ", shown); status = (code[i] == "0") ? "\033[32m\xe2\x9c\x93\033[0m" : "\033[31m\xe2\x9c\x97\033[0m"; print sprintf("%-*s\t %s \t\033[2m%8s\033[0m\t%s", w, shown, status, dur[i], cmd[i]) } }' \
        > $entries

        if test ! -s $entries
          rm -f $entries
          commandline -f $fallback
          return
        end

        set -l selection (
          fzf --read0 --ansi --no-sort --exact --layout=default --tabstop=1 --delimiter \t --with-nth 1,2,3 --nth 1 --query (commandline -b) --input-label ' History ' < $entries
        )
        set -l rc $status
        rm -f $entries

        if test $rc -eq 0 -a -n "$selection"
          commandline -r -- (string split -m 3 \t $selection)[4]
        end
        commandline -f repaint
      '';

      interactiveShellInit = lib.mkAfter ''
        bind \cr '__fzf_atuin_history history-pager'
        bind up '__fzf_atuin_history up-or-search'
      '';
    };
  };
}
