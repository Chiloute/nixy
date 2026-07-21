# Hypridle: automatic screen lock on idle and before sleep.
{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        # Re-enable the display when waking up.
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # Lock the screen after 15 minutes of inactivity.
          timeout = 900;
          on-timeout = "loginctl lock-session";
        }
        {
          # Turn the screen off shortly after locking.
          timeout = 400;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start hypridle"];
}
