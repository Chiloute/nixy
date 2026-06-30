{
  pkgs,
  pkgs-stable,
  inputs,
  system,
}:
(with pkgs-stable; [
  # Réseau & reconnaissance
  nmap
  dnsrecon
  whois
  dig
  inetutils
  samba
  openvpn

  # Web
  caido-cli
  caido-desktop
  nuclei
  katana
  gobuster
  dirb
  ffuf
  feroxbuster
  wfuzz
  sqlmap
  nosqli
  jwt-cli

  # Mots de passe & hashes
  john
  hashcat
  haiti
  hydra

  # Exploitation
  metasploit

  # Pwn / exploitation de binaires
  gdb
  gef # extension GDB orientée exploitation
  ropgadget
  one_gadget
  pwninit
  patchelf
  checksec

  # Reverse engineering
  ghidra # lourd
  radare2
  rizin
  cutter
  binutils # objdump, nm, readelf, strings
  ltrace
  strace

  # Forensics & stéganographie
  binwalk
  foremost
  scalpel
  exiftool
  steghide
  stegseek
  zsteg
  outguess
  volatility3
  testdisk

  # Crypto
  sage # lourd (RsaCtfTool n'est pas packagé : git clone)
  openssl

  # Analyse & secrets
  termshark # wireshark en TUI
  trufflehog

  # Clients data
  mariadb
  redis

  # Utilitaires
  socat
  netcat-gnu
  cyberchef
  jq
  hexyl
])
++ [
  inputs.spilltea.packages.${system}.default
  inputs.jwt-tui.packages.${system}.default
]
