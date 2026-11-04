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
  # Same wipe-on-session-boundary policy cliphist had: history is otherwise kept
  # encrypted on disk through gnome-keyring.
  clipboardClear = "noctalia msg clipboard-clear";
in {
  imports = [
    inputs.noctalia.homeModules.default
    ./palette.nix
  ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      shell = {
        font_family = config.stylix.fonts.sansSerif.name;
        # Hyprland runs under uwsm: launch apps in their own systemd scope, like the binds do.
        launch_apps_custom_command = "uwsm app -- $CMD";
      };

      # Password only: fprint and u2f are off on PAM "login", the stack this lock uses.
      lockscreen.fingerprint = false;

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

      hooks = {
        started = clipboardClear;
        logging_out = clipboardClear;
        rebooting = clipboardClear;
        shutting_down = clipboardClear;
      };
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
