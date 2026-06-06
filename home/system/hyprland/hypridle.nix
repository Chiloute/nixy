# Hypridle: automatic screen lock on idle and before sleep.
# Locking goes through `loginctl lock-session`, which the caelestia shell
# already listens to (same command as the launcher's lock action), so there
# is a single locker and no double-lock.
{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "loginctl lock-session";
        # Lock before suspend (also covers closing the lid -> logind suspends).
        before_sleep_cmd = "loginctl lock-session";
        # Re-enable the display when waking up.
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # Lock the screen after 5 minutes of inactivity.
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          # Turn the screen off shortly after locking.
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # Suspend after 15 minutes (battery saving; tune or remove freely).
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # hyprland.systemd is disabled, so graphical-session.target may not start the
  # service on its own. Start it explicitly, matching the polkitagent pattern.
  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start hypridle"];
}
