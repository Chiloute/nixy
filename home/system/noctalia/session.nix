# Lock, idle, night light and the control center quick toggles.
{...}: {
  programs.noctalia.settings = {
    # Noctalia drives fprintd itself over D-Bus, so pam_fprintd stays off on PAM
    # "login" (nixos/fprintd.nix) to avoid both claiming the sensor.
    lockscreen.fingerprint = true;

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

    # Schedule from [location] (sunset/sunrise in Paris).
    nightlight.enabled = true;

    control_center.shortcuts = map (type: {inherit type;}) [
      "wifi"
      "bluetooth"
      "caffeine"
      "mic_mute"
      "power_profile"
      "nightlight"
      "notification"
      "clipboard"
    ];

    notification.follow_focused_output = true; # three monitors: show toasts where I work
  };
}
