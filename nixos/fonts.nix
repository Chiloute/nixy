# Fonts configuration for NixOS
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      roboto
      work-sans
      comic-neue
      source-sans
      comfortaa
      inter
      lato
      lexend
      jost
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
      openmoji-color
      twemoji-color-font
      # KPS beamer theme (fontspec): text + code; titles fall back to Poppins Bold
      poppins
      jetbrains-mono
    ];

    enableDefaultPackages = false;
  };
}
