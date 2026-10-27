# zathura: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # Folders readable by apps that open documents (same list as the XDG user dirs)
  userDirs = ["Cyber" "Desktop" "Documents" "Downloads" "Music" "Notes" "Pictures" "Projects" "Videos"];

  # No network, no D-Bus, reads the user dirs, writes only its history and bookmarks.
  # No D-Bus means no vimtex synctex backward search from the viewer.
  zathura = mkSandbox.wrap {
    package = pkgs.zathura;
    gui = true;
    config = {sloth, ...}: {
      flatpak = {
        appId = "org.pwmt.zathura";
        desktopFile = "org.pwmt.zathura.desktop";
      };
      bubblewrap = {
        bind.ro = inHome sloth userDirs;
        bind.rw = inHome sloth [".local/share/zathura"];
      };
    };
  };
in {
  home.packages = [zathura];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.local/share/zathura 0700 - - -"
  ];
}
