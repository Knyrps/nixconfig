{ osConfig, config, lib, ... }:

let
  cfg = config.features.wezterm;
  has = osConfig.host.has;
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
          },
        }
      '';
    };
  };
}
