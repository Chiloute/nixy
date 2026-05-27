{ ... }: {
  # Swap compressé en RAM — économise les writes SD, améliore les perfs
  zramSwap = {
    enable    = true;
    algorithm = "zstd";
  };

  # /tmp en RAM
  boot.tmp = {
    useTmpfs  = true;
    tmpfsSize = "20%";
  };

  # Limiter la taille des journaux pour préserver la carte SD
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=10M
  '';

  # Exploiter les 4 cœurs du RPi4 pour les builds Nix
  nix.settings.max-jobs = 4;

  # GC automatique quand l'espace disque est bas (carte SD 30GB)
  nix.settings.min-free = 1073741824;  # déclenche le GC si < 1GB libre
  nix.settings.max-free = 3221225472;  # libère jusqu'à avoir 3GB libres

  # Garder seulement 2 générations (économise ~5-10GB)
  boot.loader.generic-extlinux-compatible.configurationLimit = 2;
  nix.gc = {
    automatic = true;
    persistent = true;
    dates      = "weekly";
    options    = "--delete-older-than 3d";
  };
}
