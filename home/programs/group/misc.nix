{pkgs-stable, ...}: {
  home.packages = with pkgs-stable; [
    peaclock
    pipes
    cbonsai
    fastfetch
  ];
}
