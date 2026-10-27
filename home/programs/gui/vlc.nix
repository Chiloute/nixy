# vlc: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # No network, no D-Bus, reads the user dirs, writes only its own state
  vlc = mkSandbox.wrap {
    package = pkgs.vlc;
    gui = true;
    config = {sloth, ...}: {
      flatpak = {
        appId = "org.videolan.VLC";
        desktopFile = "vlc.desktop";
      };
      bubblewrap = {
        bind.ro = inHome sloth ["Cyber" "Documents" "Downloads" "Music" "Pictures" "Videos"];
        bind.rw = inHome sloth [".config/vlc" ".local/share/vlc" ".cache/vlc"];
        sockets = {
          pipewire = true;
          pulse = true;
        };
      };
    };
  };
in {
  home.packages = [vlc];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/vlc 0700 - - -"
    "d %h/.local/share/vlc 0700 - - -"
    "d %h/.cache/vlc 0700 - - -"
  ];
}
