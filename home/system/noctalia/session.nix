# Lock, idle, night light and the control center quick toggles.
{...}: {
  programs.noctalia.settings = {
    # Replaces hypridle. Locking before sleep (lid, systemctl suspend) is built in:
    # lockscreen.lock_before_suspend defaults to true.
    idle.behavior = {
      lock = {
        timeout = 300;
        action = "lock";
        enabled = true;
      };
      screen-off = {
        timeout = 360;
        action = "screen_off";
        enabled = true;
      };
      suspend = {
        timeout = 1800;
        action = "suspend";
        enabled = true;
      };
    };
  };
}
