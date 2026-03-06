{pkgs, ...}: {
  # TODO:
  # Before add this file to your home.nix you need to follow this step
  # sudo sbctl create-keys
  # After this step you need to enroll your key
  # Your need to restart and go to your BIOS and enter to secure boot setup mode
  # Check the doc before use this command : sudo sbctl enroll-keys --microsoft
  # https://wiki.nixos.org/wiki/Limine#Enable_UEFI_Secure_Boot_Setup_Mode

  boot = {
    bootspec.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;
        # Before enable secure boot option you need
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

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
