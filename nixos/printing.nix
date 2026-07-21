# Impression réseau Epson via CUPS + découverte mDNS (Avahi).
{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      epson-escpr
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
