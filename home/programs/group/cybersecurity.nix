{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    nmap
    burpsuite
    john
    hashcat
    caido-cli
    nuclei
  ];
}
