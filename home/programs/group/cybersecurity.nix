{pkgs-stable, ...}: {
  home.packages = with pkgs-stable; [
    wireshark
    nmap
    burpsuite
    john
    hashcat
    caido
    nuclei
    gobuster
    dirb

    # Utils
    inetutils
    samba
    openvpn
    mariadb
    redis
  ];
}
