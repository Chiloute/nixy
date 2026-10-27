{config, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/memory.nix

    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/power.nix
    ../../nixos/hyprland.nix
    ../../nixos/podman.nix
    ../../nixos/limine.nix
    ../../nixos/wireshark.nix
    ../../nixos/autologin.nix # Skip first TUIGreet login, use LUKS password to unlock the keyring
    ../../home/programs/gui/helium/system.nix # I hate browser's configuration..

    ../../nixos/tuigreet.nix
    ../../nixos/kernel-hardening.nix
    ../../nixos/fwupd.nix
    ../../nixos/fprintd.nix
    ../../nixos/libvirt.nix
    ./usbguard.nix
    ../../nixos/yubikey.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # TRIM through LUKS (fstrim never reached the SSD) and skip dm-crypt workqueues on NVMe.
  boot.initrd.luks.devices."luks-61744d98-361e-48b7-8c56-f9411e45ad7f" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "26.05";
}
