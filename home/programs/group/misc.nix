{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}: {
  home.packages = with pkgs-stable; [
    peaclock
    pipes
    cbonsai
    fastfetch
    inputs.usbguard-tui.packages.${pkgs-stable.stdenv.hostPlatform.system}.default
  ];
}
