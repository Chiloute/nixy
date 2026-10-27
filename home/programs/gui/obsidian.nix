# obsidian: sandboxed with nixpak (see ../../lib/sandbox.nix)
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  # Network (community plugins), only its config and ~/Notes
  obsidian = mkSandbox.wrap {
    package = pkgs.obsidian;
    gui = true;
    config = {sloth, ...}: {
      dbus.enable = true; # portal: links, file chooser
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/obsidian" "Notes"];
      };
    };
  };
in {
  home.packages = [obsidian];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/obsidian 0700 - - -"
    "d %h/Notes 0755 - - -"
  ];
}
