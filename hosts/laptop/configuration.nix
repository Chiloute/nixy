{config, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix

    ../../nixos/users.nix
    ../../nixos/utils.nix
    # ../../nixos/power.nix
    ../../nixos/hyprland.nix
    ../../nixos/docker.nix
    ../../nixos/limine.nix
    ../../nixos/wireshark.nix
    ../../nixos/autologin.nix # Skip first TUIGreet login, use LUKS password to unlock the keyring
    ../../home/programs/gui/helium/system.nix # I hate browser's configuration..

    ../../nixos/usbguard.nix
    ../../nixos/tuigreet.nix
    ../../nixos/kernel-hardening.nix
    ../../nixos/fwupd.nix
    ../../nixos/fprintd.nix
    ./usbguard.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "26.05";
}
