# Impermanence: declares what should survive a wipe of "/".
# /home is its own btrfs subvolume (see disko.nix), so nothing from home is listed here.
{config, ...}: {
  fileSystems."/persist".neededForBoot = true;

  # /etc/shadow is wiped on every boot: the password must come from /persist.
  # Create it before the first boot: mkpasswd -m yescrypt > /mnt/persist/secrets/<user>.hash
  users.mutableUsers = false;
  users.users.${config.var.username}.hashedPasswordFile = "/persist/secrets/${config.var.username}.hash";

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections" # Wifi connections, VPN
      "/var/lib/NetworkManager" # leases, seen networks
      "/var/lib/bluetooth" # Bluetooth pairings
      "/var/lib/nixos" # keeps uid/gid stable across boots
      "/var/lib/sbctl" # Secure Boot keys: losing them means re-enrolling in the firmware
      "/var/lib/fprint" # enrolled fingerprints
      "/var/lib/fwupd"
      "/var/lib/libvirt" # VMs and their disks
      "/var/lib/containers" # rootful podman images
      "/var/lib/usbguard"
      "/var/lib/power-profiles-daemon"
      "/var/lib/systemd/coredump"
      "/var/lib/upower" # battery calibration state
      "/var/lib/systemd/backlight" # remembers screen brightness
      "/var/lib/systemd/timers" # last-run timestamps (e.g. nix gc weekly)
      "/var/log"
      "/var/cache/tuigreet"
      "/var/db/sudo/lectured" # remembers that the sudo lecture was already shown
    ];

    files = [
      "/etc/machine-id"
      "/var/lib/systemd/random-seed" # avoid a weak entropy pool on first boot
    ];
  };
}
