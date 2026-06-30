{config, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/sddm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    # ../../nixos/power.nix
    ../../nixos/hyprland.nix
    ../../nixos/docker.nix
    ../../nixos/limine.nix
    ../../nixos/wireshark.nix

    ../../nixos/usbguard.nix
    ../../nixos/tuigreet.nix
    ../../nixos/kernel-hardening.nix
    ../../nixos/fwupd.nix
    ../../nixos/fprintd.nix
    ../../nixos/printing.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # USBGuard:
  # Allow all USB devices until a proper policy is configured.
  # Run `sudo usbguard generate-policy` with your devices plugged in,
  # then set rules = "<output>" and switch implicitPolicyTarget to "block".
  # services.usbguard.implicitPolicyTarget = lib.mkForce "allow";

  services.usbguard.rules = ''
    # Internal devices — generated on this machine with `usbguard generate-policy`.
    allow id 1d6b:0002 serial "0000:00:0d.0" name "xHCI Host Controller" hash "d3YN7OD60Ggqc9hClW0/al6tlFEshidDnQKzZRRk410=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0003 serial "0000:00:0d.0" name "xHCI Host Controller" hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
    # Synaptics fingerprint reader
    allow id 06cb:0123 serial "f4f46df26eb0" name "" hash "roVqyEnVpJ7AEhDwWWz599bLBfUiHeluIsHMsWYpWyU=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface ff:00:00 with-connect-type "not used"
    allow id 30c9:005f serial "0001" name "Integrated Camera" hash "X1L3AAQB4RK76RF5BOuT3mtNGEAhsT4pVzUKCCxUlFo=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "not used"
    # Intel Bluetooth
    allow id 8087:0036 serial "" name "" hash "XwbcZSrllifsnXXcFkmww6DJnTpumS/N2rYZllwTvH4=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"

    # External trusted devices (matched by VID:PID only — practical for removable media).
    # Plug each in and re-run `usbguard generate-policy` if you want hash-pinned rules.
    allow id 0634:5602 name "Crucial X8 SSD"
    allow id 0781:5591 name " SanDisk 3.2Gen1"
  '';

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
