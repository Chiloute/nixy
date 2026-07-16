{
  pkgs,
  pkgs-stable,
  ...
}:
(with pkgs-stable; [
  # Réseau & reconnaissance
  nmap
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
  steghide
  stegseek
  zsteg
  outguess
  volatility3
  testdisk

  # Crypto
  openssl

  # Analyse & secrets
  termshark # wireshark en TUI
  trufflehog

  # Tools
  exploitdb
])
++ [pkgs.dnsrecon]
++ (with pkgs.nur.repos.anotherhadi; [
  spilltea
  jwt-tui
])
