# pinta: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # No network, ~/Pictures, anything else through the file chooser
  pinta = mkSandbox.wrap {
    package = pkgs.pinta;
    gui = true;
    config = {sloth, ...}: {
      flatpak.appId = "com.github.PintaProject.Pinta"; # = its .desktop ID, for files handed over by the portal
      dbus.enable = true; # portal: file chooser
      bubblewrap.bind.rw = inHome sloth [".config/Pinta" "Pictures"];
    };
  };
in {
  home.packages = [pinta];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/Pinta 0700 - - -"
  ];
}
