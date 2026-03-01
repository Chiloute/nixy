{pkgs, ...}: {
  boot = {
    bootspec.enable = true;

    loader = {
      efi.canTouchEfiVariables = true;
      # sbctl is used to securely generate & store the Secure Boot keys. Generating the keys is as simple as:

      limine = {
        enable = true;
        # Before enable secure boot option you need
        # sudo sbctl create-key
        secureBoot.enable = true;
        maxGenerations = 5;
        secureBoot.sbctl = pkgs.sbctl;
        extraEntries = ''
          /Windows
            protocol: efi
            path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
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
