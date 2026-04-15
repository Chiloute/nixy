{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    wireshark
    nmap
    john
    hashcat
    caido
    nuclei
  ];
}
