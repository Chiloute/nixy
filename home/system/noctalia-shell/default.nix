# Noctalia Shell Home Manager Configuration
# See https://docs.noctalia.dev/v4
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "right"; # vertical bar on the right edge
        showCapsule = false;
        # For a vertical bar: "left" = top, "right" = bottom.
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {id = "Launcher";}
            {id = "Network";}
            {id = "Bluetooth";}
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "none";
            }
          ];
          right = [
            {id = "SystemMonitor";}
            {id = "KeyboardLayout";}
            {id = "Volume";}
            {id = "Brightness";}
            {id = "NotificationHistory";}
            {id = "Tray";}
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };

      colorSchemes = {
        predefinedScheme = "Monochrome";
        darkMode = true;
      };

      general = {
        avatarImage = "/home/${config.var.username}/.face";
        radiusRatio = 0.2;
        # Lock screen behaviour (laptop): lock when suspending.
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
      };

      location = {
        name = "Paris, France";
        weatherEnabled = true;
        useFahrenheit = false;
        use12hourFormat = false;
        firstDayOfWeek = 1; # Monday
      };

      # Audio / volume (OSD + control center)
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
      };

      # Display backlight
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
      };

      network = {
        bluetoothAutoConnect = true;
      };

      notifications = {
        enabled = true;
        location = "top_right";
      };

      # NOTE: wallpaper management is left to hyprpaper (see ../hyprpaper),
      # so Noctalia's own wallpaper engine stays off to avoid two daemons
      # fighting over the background.
      wallpaper.enabled = false;

      # NOTE: idle/screen-off is handled by hypridle (see ../hyprland/hypridle.nix);
      # enable here only if you drop hypridle, otherwise both will fire.
      idle.enabled = false;
    };
  };

  # The home module installs the package + config but does not autostart the
  # shell (its systemd integration is deprecated), so launch it from Hyprland.
  wayland.windowManager.hyprland.settings.exec-once = [
    "uwsm app -- noctalia-shell"
  ];
}
