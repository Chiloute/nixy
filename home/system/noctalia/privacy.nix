# Network, plugin and data-retention settings of the shell. Reviewed in docs/SECURITY.md.
{
  inputs,
  pkgs,
  ...
}: let
  # Only the reviewed plugins are exposed, not the whole community repo.
  pinnedPlugins = pkgs.linkFarm "noctalia-plugins" [
    {
      name = "hypr-screen-mirror"; # profidev/hypr-screen-mirror: monitor mirroring via hyprctl eval
      path = "${inputs.noctalia-community-plugins}/hypr-screen-mirror";
    }
  ];

  # Same wipe-on-session-boundary policy cliphist had: history is otherwise kept
  # encrypted on disk through gnome-keyring.
  clipboardClear = "noctalia msg clipboard-clear";
in {
  # hypr-screen-mirror watches the Hyprland event socket through socat on PATH.
  home.packages = [pkgs.socat];

  programs.noctalia.settings = {
    shell = {
      # Pinned here so the Settings UI can't flip them silently.
      telemetry_enabled = false;
      external_ip_enabled = false;
      # Don't keep a secret pasteable after Proton Pass exits.
      clipboard_keep_from_closed_apps = false;
      clipboard_history_max_entries = 20;
    };

    # No plugin code fetched or auto-updated from git. To add one, pin
    # noctalia-dev/official-plugins as a flake input and declare it as a
    # kind = "path" source (read-only for Noctalia).
    plugins = {
      auto_update = "none";
      enabled = ["profidev/hypr-screen-mirror"];
      source = [
        {
          name = "pinned";
          kind = "path";
          location = "${pinnedPlugins}";
          enabled = true;
        }
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = false;
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          enabled = false;
        }
      ];
    };

    notification = {
      history_retention_hours = 24;
      # Message content from these never lands in the on-disk history.
      filter_order = ["private"];
      filter.private = {
        enabled = true;
        match = "signal";
        save_history = false;
      };
    };

    # Stylix themes apps from the same base16; community templates also fetch
    # and run remote hooks.
    theme.templates = {
      enable_builtin_templates = false;
      enable_community_templates = false;
    };

    hooks = {
      started = [clipboardClear];
      logging_out = clipboardClear;
      rebooting = clipboardClear;
      shutting_down = clipboardClear;
    };
  };
}
