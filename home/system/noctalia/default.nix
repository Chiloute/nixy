# Noctalia v5: bar, launcher, notifications, OSD, control center, wallpaper.
# Settings land in ~/.config/noctalia/config.toml (read-only). Changes made in the
# Settings UI go to ~/.local/state/noctalia/settings.toml and win over these;
# backport them with `noctalia config export`.
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  hl = import ../hyprland/lua.nix {inherit lib;};
in {
  imports = [
    inputs.noctalia.homeModules.default
    ./palette.nix
    ./privacy.nix
    ./session.nix
  ];

  # Noctalia draws the wallpaper; stylix would otherwise still start hyprpaper under it.
  stylix.targets.hyprland.hyprpaper.enable = false;

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      shell = {
        font_family = config.stylix.fonts.sansSerif.name;
        # Hyprland runs under uwsm: launch apps in their own systemd scope, like the binds do.
        launch_apps_custom_command = "uwsm app -- $CMD";
      };

      wallpaper = {
        enabled = true;
        default.path = "${config.stylix.image}";
      };

      theme = {
        mode = config.stylix.polarity;
        source = "custom";
        custom_palette = "Stylix";
      };

      location.address = config.var.location;

      # The Settings UI saves wallpaper picks in ~/.local/state and they win over
      # wallpaper.default; re-apply the stylix one on every shell start.
      hooks.started = ["noctalia msg wallpaper-set ${config.stylix.image}"];
    };
  };

  wayland.windowManager.hyprland.settings = {
    on = [(hl.onStart "noctalia")];

    layer_rule = [
      {
        name = "noctalia";
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
        no_anim = true;
        ignore_alpha = 0.5;
        blur = true;
        blur_popups = true;
      }
    ];

    window_rule = [
      {
        match.class = "dev.noctalia.Noctalia";
        float = true;
        size = "1080 920";
      }
    ];
  };
}
