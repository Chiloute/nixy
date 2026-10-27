# HyprPolkitAgent is a simple polkit agent for wayland compositors
{
  pkgs,
  lib,
  ...
}: let
  hl = import ./lua.nix {inherit lib;};
in {
  home.packages = with pkgs; [hyprpolkitagent];

  wayland.windowManager.hyprland.settings.on = [(hl.onStart "systemctl --user start hyprpolkitagent")];
}
