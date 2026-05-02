{pkgs-stable, ...}: {
  home.packages = with pkgs-stable; [
    vlc # Video player
    obsidian # Note taking app
    textpieces # Manipulate texts
    resources # Ressource monitor
    gnome-clocks # Clocks app
    gnome-text-editor # Basic graphic text editor
    onlyoffice-desktopeditors # Office
    discord
    signal-desktop # Messaging app

    firefox
  ];
}
