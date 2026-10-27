# Hyprpaper is used to set the wallpaper on the system
{lib, ...}: let
  hl = import ./lua.nix {inherit lib;};
in {
  # The wallpaper is set by stylix
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
    };
  };
  systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";

  wayland.windowManager.hyprland.settings.on = [
    (hl.onStart "systemctl --user enable --now hyprpaper.service")
  ];
}
