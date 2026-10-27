# discord: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # Network, audio, webcam, screen sharing (portal + PipeWire), its own data, ~/Downloads
  discord = mkSandbox.wrap {
    package = pkgs.discord;
    gui = true;
    config = {sloth, ...}: {
      dbus = {
        enable = true;
        policies = {
          "org.freedesktop.Notifications" = "talk";
          "org.freedesktop.secrets" = "talk";
          # Tray icon
          "org.kde.StatusNotifierWatcher" = "talk";
          "org.kde.*" = "own";
        };
      };
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/discord" "Downloads"];
        bind.ro = inHome sloth ["Documents" "Pictures" "Videos"] ++ ["/sys/class/video4linux"]; # attachments, webcam
        sockets = {
          pipewire = true; # voice, screen sharing
          pulse = true;
        };
        bind.dev = ["/dev/video0" "/dev/video1" "/dev/video2" "/dev/video3"];
      };
    };
  };
in {
  home.packages = [discord];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/discord 0700 - - -"
  ];
}
