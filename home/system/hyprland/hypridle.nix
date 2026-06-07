# Hypridle: automatic screen lock on idle and before sleep.
# Locking goes through `loginctl lock-session`, which the caelestia shell
# already listens to (same command as the launcher's lock action), so there
# is a single locker and no double-lock.
{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # IMPORTANT: lock_cmd is the handler hypridle runs *when it receives*
        # logind's Lock event (loginctl lock-session) — it is NOT "the command
        # used to lock". Setting it to "loginctl lock-session" makes it re-emit
        # the Lock event it just received, creating an infinite Lock loop that
        # re-locks the session over and over and prevents unlocking from
        # sticking. The caelestia shell already locks on logind's Lock event,
        # so lock_cmd stays empty; we only *trigger* locking from the idle
        # listener (on-timeout) and before_sleep_cmd below.

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
          # Suspend after 15 minutes of inactivity (battery saving).
          # The previous sleep/wake loop was NOT caused by this listener but
          # by lock_cmd re-emitting the Lock event (see the note above), which
          # also fired through before_sleep_cmd around suspend. With lock_cmd
          # left empty this is safe again.
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
