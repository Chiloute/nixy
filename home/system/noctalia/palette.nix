# Noctalia palette generated from the stylix base16 scheme, so every theme in
# themes/ also themes the shell. Light is omitted: Noctalia reuses dark for both.
{config, ...}: let
  b = name: "#${config.lib.stylix.colors.${name}}";
in {
  programs.noctalia.customPalettes.Stylix = {
    version = 2;
    dark = {
      primary = b "base0D";
      on_primary = b "base00";
      secondary = b "base0E";
      on_secondary = b "base00";
      tertiary = b "base0C";
      on_tertiary = b "base00";
      error = b "base08";
      on_error = b "base00";
      surface = b "base00";
      on_surface = b "base05";
      on_surface_variant = b "base04";
      surface_container = b "base01";
      outline_variant = b "base03";
      shadow = b "base00";
      hover = b "base02";
      on_hover = b "base05";
      terminal = {
        background = b "base00";
        foreground = b "base05";
        cursor = b "base05";
        cursor_text = b "base00";
        selection_bg = b "base02";
        selection_fg = b "base05";
        normal = {
          black = b "base01";
          red = b "base08";
          green = b "base0B";
          yellow = b "base0A";
          blue = b "base0D";
          magenta = b "base0E";
          cyan = b "base0C";
          white = b "base05";
        };
        bright = {
          black = b "base03";
          red = b "base08";
          green = b "base0B";
          yellow = b "base0A";
          blue = b "base0D";
          magenta = b "base0E";
          cyan = b "base0C";
          white = b "base07";
        };
      };
    };
  };
}
