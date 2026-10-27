# libreoffice: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  userDirs = ["Cyber" "Desktop" "Documents" "Downloads" "Music" "Notes" "Pictures" "Projects" "Videos"];

  # nixpak can't rewrite libreoffice's bin/* (symlinks into lib/): wrap a real executable instead.
  # Only `libreoffice` is exposed, so swriter & co can't bypass the sandbox.
  libreofficeEntry =
    pkgs.runCommand "libreoffice-entry" {
      meta.mainProgram = "libreoffice";
    } ''
      mkdir -p $out/bin $out/share
      printf '#!${pkgs.runtimeShell}\nexec ${pkgs.libreoffice}/bin/libreoffice "$@"\n' > $out/bin/libreoffice
      chmod +x $out/bin/libreoffice
      cp -rL ${pkgs.libreoffice}/share/applications ${pkgs.libreoffice}/share/icons $out/share/
    '';

  # No network, no D-Bus, reads the user dirs, writes ~/Documents and ~/Downloads
  libreoffice = mkSandbox.wrap {
    package = libreofficeEntry;
    gui = true;
    config = {sloth, ...}: {
      flatpak.appId = "org.libreoffice.LibreOffice";
      bubblewrap = {
        bind.ro = inHome sloth (builtins.filter (d: d != "Documents" && d != "Downloads") userDirs);
        bind.rw = inHome sloth [".config/libreoffice" "Documents" "Downloads"];
      };
    };
  };
in {
  home.packages = [libreoffice];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/libreoffice 0700 - - -"
  ];
}
