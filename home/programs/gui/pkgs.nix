{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    firefox

    # Backup
    thunar
    gnome-text-editor
  ];
}
