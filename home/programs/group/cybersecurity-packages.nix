{
  inputs,
  pkgs,
}: (with pkgs; [
  # Web
  dirb
  ffuf
  katana
  whatweb
  sqlmap
  nosqli

  # Hashes
  hashcat
  haiti
  john

  # Databases
  mariadb
  redis

  # Network
  inetutils
  termshark # wireshark in TUI
  whois
  dig
  nmap
  samba
  hydra

  # Misc
  metasploit
  nuclei
  openvpn

  # Secrets
  trufflehog

  # Forensics
  binwalk
  pkgs.nur.repos.anotherhadi.spilltea
  inputs.jwt-tui.packages.${pkgs.stdenv.hostPlatform.system}.default
])
