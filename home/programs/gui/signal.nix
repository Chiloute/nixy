# signal: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # Network, its own data, Documents and Downloads (attachments)
  signal = mkSandbox.wrap {
    package = pkgs.signal-desktop;
    gui = true;
    config = {sloth, ...}: {
      dbus = {
        enable = true;
        policies = {
          "org.freedesktop.Notifications" = "talk";
          "org.freedesktop.secrets" = "talk"; # database key, stored in the keyring
          # Tray icon: Signal starts minimized to the tray, without it the window can't be reopened
          "org.kde.StatusNotifierWatcher" = "talk";
          "org.kde.*" = "own";
        };
      };
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/Signal" "Documents" "Downloads"];
        sockets = {
          pipewire = true; # calls, voice notes
          pulse = true;
        };
        # Webcam for video calls (Chromium opens the V4L2 devices directly)
        bind.dev = ["/dev/video0" "/dev/video1" "/dev/video2" "/dev/video3"];
        bind.ro = ["/sys/class/video4linux"];
      };
    };
  };
in {
  home.packages = [signal];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/Signal 0700 - - -"
  ];
}
