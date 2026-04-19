{pkgs-stable, ...}: {
  home.packages = with pkgs-stable; [
    peaclock
    pipes
    fastfetch
  ];
}
