{pkgs, ...}: {
  boot = {
    bootspec.enable = true;

    loader = {
      efi.canTouchEfiVariables = true;

      limine.enable = true;
      limine.secureBoot.enable = true;
      limine.maxGenerations = 5;
      limine.extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };

    tmp.cleanOnBoot = true;

    kernelPackages = pkgs.linuxPackages_latest;

    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];

    consoleLogLevel = 0;
    initrd.verbose = false;
  };
  # Pour éviter les blocages à l’arrêt
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
