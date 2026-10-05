{ osConfig, config, lib, ... }:

let
  t = osConfig.theme;
  b = t.base16;
  c = t.lib;
  alpha = c.withAlpha;
  dark = c.darken;
  none = "#00000000";
  syn = color: font_style: { inherit color font_style; };
  status = col: {
    "${col.n}" = col.c;
    "${col.n}.background" = alpha col.c 0.1;
    "${col.n}.border" = dark col.c 0.4;
  };
  statuses = lib.foldl' (acc: x: acc // status x) { } [
    { n = "hint"; c = b.base0D; }
    { n = "info"; c = b.base0C; }
    { n = "success"; c = b.base0B; }
    { n = "warning"; c = b.base0A; }
    { n = "error"; c = b.base0F; }
    { n = "created"; c = b.base0B; }
    { n = "modified"; c = b.base0A; }
    { n = "deleted"; c = b.base08; }
    { n = "conflict"; c = b.base0A; }
    { n = "renamed"; c = b.base0D; }
    { n = "hidden"; c = b.base03; }
    { n = "ignored"; c = b.base03; }
    { n = "predictive"; c = b.base0E; }
    { n = "unreachable"; c = b.base03; }
  ];
  ansi = name: col: {
    "terminal.ansi.${name}" = col;
    "terminal.ansi.bright_${name}" = col;
    "terminal.ansi.dim_${name}" = col;
  };
  player = col: { cursor = col; background = col; selection = alpha col 0.25; };
in
{
  config = lib.mkIf config.features.zed.enable {
    programs.zed-editor = {
      userSettings.theme = t.name;

      themes.${t.name} = {
        name = t.name;
        author = "knyrps";
        themes = [
          {
            name = t.name;
            appearance = "dark";
            style = {
              background = b.base01;
              "surface.background" = b.base00;
              "elevated_surface.background" = b.base00;
              "panel.background" = b.base00;
              "panel.focused_border" = none;
              "panel.indent_guide" = alpha b.base06 0.1;
              "panel.indent_guide_hover" = alpha b.base06 0.3;
              "panel.indent_guide_active" = alpha b.base06 0.3;
              "pane.focused_border" = none;
              "pane.group_border" = none;
              border = b.base02;
              "border.variant" = b.base02;
              text = b.base06;
              "text.muted" = b.base05;
              "text.placeholder" = b.base04;
              "text.disabled" = b.base04;
              "text.accent" = b.base09;
              "link_text.hover" = b.base09;
              icon = b.base06;
              "icon.muted" = b.base05;
              "icon.disabled" = b.base04;
              "icon.accent" = b.base09;
              "editor.foreground" = b.base05;
              "editor.background" = b.base00;
              "editor.gutter.background" = b.base00;
              "editor.active_line.background" = b.base02;
              "editor.subheader.background" = b.base01;
              "editor.active_line_number" = b.base05;
              "editor.line_number" = b.base03;
              "editor.hover_line_number" = b.base04;
              "editor.invisible" = alpha b.base06 0.1;
              "editor.wrap_guide" = alpha b.base06 0.1;
              "editor.active_wrap_guide" = alpha b.base06 0.3;
              "editor.indent_guide" = alpha b.base06 0.1;
              "editor.indent_guide_active" = alpha b.base06 0.3;
              "editor.document_highlight.read_background" = alpha b.base0D 0.2;
              "editor.document_highlight.write_background" = alpha b.base03 0.3;
              "status_bar.background" = b.base01;
              "title_bar.background" = b.base01;
              "title_bar.inactive_background" = b.base01;
              "toolbar.background" = b.base00;
              "element.background" = b.base01;
              "element.hover" = b.base02;
              "element.active" = b.base02;
              "element.selected" = b.base02;
              "element.disabled" = b.base01;
              "ghost_element.background" = none;
              "ghost_element.disabled" = b.base02;
              "ghost_element.hover" = b.base02;
              "ghost_element.active" = b.base02;
              "ghost_element.selected" = b.base02;
              "drop_target.background" = alpha b.base03 0.5;
              "tab_bar.background" = b.base01;
              "tab.inactive_background" = b.base01;
              "tab.active_background" = b.base00;
              "scrollbar.thumb.background" = alpha b.base05 0.3;
              "scrollbar.thumb.hover_background" = alpha b.base05 0.5;
              "scrollbar.thumb.active_background" = alpha b.base05 0.5;
              "scrollbar.thumb.border" = b.base02;
              "scrollbar.track.background" = none;
              "scrollbar.track.border" = b.base02;
              "version_control.added" = b.base0B;
              "version_control.deleted" = b.base08;
              "version_control.modified" = b.base0A;
              "version_control.renamed" = b.base0D;
              "version_control.conflict" = b.base0A;
              "version_control.ignored" = b.base03;
              "version_control.word_added" = alpha (dark b.base0B 0.1) 0.3;
              "version_control.word_deleted" = alpha (dark b.base0F 0.1) 0.3;
              "version_control.conflict_marker.ours" = alpha b.base0B 0.1;
              "version_control.conflict_marker.theirs" = alpha b.base0D 0.1;
              "terminal.background" = b.base00;
              "terminal.foreground" = b.base05;
              "terminal.bright_foreground" = b.base06;
              "terminal.dim_foreground" = b.base04;
              players = map player [ b.base09 b.base0D b.base0A b.base0B b.base0C b.base0E b.base08 b.base0F ];
              syntax = {
                angle = syn b.base05 null;
                arithmetic = syn b.base0C null;
                attribute = syn b.base0D null;
                attributeBracket = syn b.base05 null;
                bitwise = syn b.base0C null;
                boolean = syn b.base09 null;
                brace = syn b.base05 null;
                bracket = syn b.base05 null;
                builtinAttribute = syn b.base0D null;
                builtinType = syn b.base09 null;
                character = syn b.base0B null;
                colon = syn b.base05 null;
                comma = syn b.base05 null;
                comment = syn b.base04 "italic";
                "comment.doc" = syn b.base04 "italic";
                comparison = syn b.base0C null;
                const = syn b.base09 null;
                constant = syn b.base09 null;
                "constant.builtin" = syn b.base09 null;
                constParameter = syn b.base09 null;
                constructor = syn b.base0D null;
                derive = syn b.base0D null;
                deriveHelper = syn b.base0D null;
                "diff.minus" = syn b.base0F null;
                "diff.plus" = syn b.base0B null;
                dot = syn b.base05 null;
                embedded = syn b.base07 null;
                emphasis = syn b.base0D "italic";
                "emphasis.strong" = syn b.base09 "italic";
                enum = syn b.base0A null;
                enumMember = syn b.base0A null;
                escapeSequence = syn b.base0E null;
                formatSpecifier = syn b.base0E null;
                function = syn b.base0D null;
                generic = syn b.base05 null;
                hint = syn b.base03 null;
                keyword = syn b.base0E null;
                label = syn b.base0D null;
                lifetime = syn b.base05 "italic";
                link_text = syn b.base0D null;
                link_uri = syn b.base0D null;
                logical = syn b.base0C null;
                macro = syn b.base0D "italic";
                macroBang = syn b.base0E "italic";
                method = syn b.base0D null;
                namespace = syn b.base05 null;
                negation = syn b.base0C null;
                number = syn b.base09 null;
                operator = syn b.base0C null;
                parameter = syn b.base05 null;
                parenthesis = syn b.base05 null;
                predictive = syn b.base0D "italic";
                preproc = syn b.base05 null;
                primary = syn b.base05 null;
                procMacro = syn b.base0D "italic";
                property = syn b.base08 null;
                punctuation = syn b.base05 null;
                "punctuation.bracket" = syn b.base05 null;
                "punctuation.delimiter" = syn b.base05 null;
                "punctuation.list_marker" = syn b.base08 null;
                "punctuation.special" = syn b.base0F null;
                selector = syn b.base0A null;
                "selector.pseudo" = syn b.base0D null;
                selfKeyword = syn b.base09 "italic";
                selfTypeKeyword = syn b.base0A null;
                semi = syn b.base05 null;
                static = syn b.base05 null;
                string = syn b.base0B null;
                "string.escape" = syn b.base0E null;
                "string.regex" = syn b.base09 null;
                "string.special" = syn b.base0E null;
                "string.special.symbol" = syn b.base0E null;
                struct = syn b.base0A null;
                tag = syn b.base0D null;
                "tag.doctype" = syn b.base0D null;
                "text.literal" = syn b.base0B null;
                title = syn b.base08 null;
                toolModule = syn b.base0D null;
                trait = syn b.base0A null;
                type = syn b.base0A null;
                "type.builtin" = syn b.base09 null;
                typeAlias = syn b.base0A null;
                typeParameter = syn b.base0A null;
                union = syn b.base0A null;
                unresolvedReference = syn b.base0C null;
                variable = syn b.base05 null;
                "variable.parameter" = syn b.base05 null;
                "variable.special" = syn b.base0A "italic";
                variant = syn b.base0A null;
              };
            }
            // statuses
            // ansi "black" b.base00 // { "terminal.ansi.bright_black" = b.base03; "terminal.ansi.dim_black" = b.base03; }
            // ansi "red" b.base08
            // ansi "green" b.base0B
            // ansi "yellow" b.base0A
            // ansi "blue" b.base0D
            // ansi "magenta" b.base0E
            // ansi "cyan" b.base0C
            // ansi "white" b.base05;
          }
        ];
      };
    };
  };
}
