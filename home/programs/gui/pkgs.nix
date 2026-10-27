{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    vlc # Video player
    obsidian # Note taking app
    pinta # Image editor
    blanket # Listen to different sounds
    signal-desktop # Messaging app
    ticktick # Todo app
    discord
    zathura
    libreoffice
    firefox

    # Backup
    thunar
    gnome-text-editor
  ];
}
