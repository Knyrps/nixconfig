{ osConfig, config, lib, ... }:

let
  cfg = config.features.wezterm;
  has = osConfig.host.has;
  t = osConfig.theme.palette.dark.terminal;
  lua = l: "{ " + lib.concatMapStringsSep ", " (x: "\"${x}\"") l + " }";
in
{
  options.features.wezterm.enable = lib.mkEnableOption "wezterm" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;

      extraConfig = ''
        return {
          -- WebGpu avoids blurry text under fractional scaling on wayland
          front_end = "WebGpu",
          -- wgpu defaults to LowPower, which picks the UHD 630. The panel is
          -- driven by the Navi 14, so that made every frame a cross-PCIe copy.
          webgpu_power_preference = "HighPerformance",
          font = wezterm.font("${osConfig.theme.fonts.mono.name}"),
          colors = {
            foreground = "${t.foreground}",
            background = "${t.background}",
            cursor_bg = "${t.cursor}",
            cursor_fg = "${t.cursor_text}",
            cursor_border = "${t.cursor}",
            selection_bg = "${t.selection_bg}",
            selection_fg = "${t.selection_fg}",
            ansi = ${lua (with t.normal; [ black red green yellow blue magenta cyan white ])},
            brights = ${lua (with t.bright; [ black red green yellow blue magenta cyan white ])},
          },
          hide_tab_bar_if_only_one_tab = true,
          use_fancy_tab_bar = false,
          window_close_confirmation = "NeverPrompt",
          window_padding = { left = 8, right = 8, top = 8, bottom = 8 },

          keys = {
            -- free ctrl+r so it reaches atuin in the shell. wezterm registers
            -- reload under several normalisations of r/R, so unbind them all
            -- and move reload to ctrl+F5 (super+r keeps working too).
            { key = "r", mods = "CTRL",       action = wezterm.action.DisableDefaultAssignment },
            { key = "R", mods = "CTRL",       action = wezterm.action.DisableDefaultAssignment },
            { key = "R", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
            { key = "F5", mods = "CTRL",      action = wezterm.action.ReloadConfiguration },

            -- match zed's terminal: ctrl+c copies only when something is
            -- selected, otherwise it stays SIGINT. ctrl+v always pastes.
            {
              key = "c",
              mods = "CTRL",
              action = wezterm.action_callback(function(window, pane)
                local sel = window:get_selection_text_for_pane(pane)
                if sel and sel ~= "" then
                  window:perform_action(wezterm.action.CopyTo "ClipboardAndPrimarySelection", pane)
                  window:perform_action(wezterm.action.ClearSelection, pane)
                else
                  window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)
                end
              end),
            },
            { key = "v", mods = "CTRL", action = wezterm.action.PasteFrom "Clipboard" },
          },
        }
      '';
    };
  };
}
