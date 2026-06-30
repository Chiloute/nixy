# Hyprland is a dynamic tiling Wayland compositor.
{
  inputs,
  pkgs-stable,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages."${pkgs-stable.stdenv.hostPlatform.system}".hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs-stable.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
}
