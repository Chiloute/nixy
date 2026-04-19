{
  pkgs-stable,
  inputs,
  ...
}: {
  home.packages = with pkgs-stable; [
    wireshark
    nmap
    burpsuite
    john
    hashcat
    caido-cli
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
