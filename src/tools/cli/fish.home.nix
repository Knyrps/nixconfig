{ osConfig, config, lib, ... }:

let
  cfg = config.features.fish;
  p = osConfig.theme.palette.dark;
  s = osConfig.theme.lib.strip;
in
{
  options.features.fish.enable = lib.mkEnableOption "fish" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_color_normal ${s p.on_surface}
        set fish_color_command ${s p.terminal.normal.green}
        set fish_color_keyword ${s p.terminal.normal.magenta}
        set fish_color_quote ${s p.terminal.normal.yellow}
        set fish_color_redirection ${s p.terminal.normal.cyan}
        set fish_color_end ${s p.primary}
        set fish_color_error ${s p.error}
        set fish_color_param ${s p.on_surface}
        set fish_color_valid_path --underline
        set fish_color_option ${s p.terminal.normal.blue}
        set fish_color_comment ${s p.on_surface_variant}
        set fish_color_selection --background=${s p.hover}
        set fish_color_operator ${s p.terminal.normal.cyan}
        set fish_color_escape ${s p.terminal.normal.magenta}
        set fish_color_autosuggestion ${s p.outline}
        set fish_color_search_match --background=${s p.hover}
        set fish_color_cancel ${s p.error}
        set fish_pager_color_prefix ${s p.primary}
        set fish_pager_color_completion ${s p.on_surface}
        set fish_pager_color_description ${s p.on_surface_variant}
        set fish_pager_color_progress ${s p.on_surface_variant}
        set fish_pager_color_selected_background --background=${s p.hover}
      '';
    };
  };
}
