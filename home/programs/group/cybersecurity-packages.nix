{
  pkgs,
  pkgs-stable,
  inputs,
  system,
}:
(with pkgs-stable; [
  termshark # wireshark
  trufflehog
  nmap
  john
  hashcat
  metasploit
  haiti
  hydra
  dnsrecon
  whois
  dig
  nosqli
  jwt-cli
  nuclei
  caido-cli
  caido-desktop
  gobuster
  dirb
  ffuf
  sqlmap
  katana
  inetutils
  samba
  openvpn
  mariadb
  redis
])
++ [
  inputs.spilltea.packages.${system}.default
  inputs.jwt-tui.packages.${system}.default
]
