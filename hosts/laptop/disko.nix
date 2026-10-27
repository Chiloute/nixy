# Impermanence layout for nvme0n1p5 ONLY (partlabel "root").
# The disk is shared with Windows: never point disko at the whole disk,
# and never let it touch the ESP (nvme0n1p1, also holds the Windows bootloader).
# "/" is a tmpfs; only /nix, /persist and /home survive a reboot.
{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["defaults" "size=4G" "mode=755"];
    };

    disk.nixos = {
      type = "disk";
      device = "/dev/disk/by-partlabel/root";
      content = {
        type = "luks";
        name = "crypted";
        settings = {
          allowDiscards = true;
          bypassWorkqueues = true;
        };
        content = {
          type = "btrfs";
          extraArgs = ["-f"];
          subvolumes = {
            "/nix" = {
              mountpoint = "/nix";
              mountOptions = ["compress=zstd" "noatime"];
            };
            "/persist" = {
              mountpoint = "/persist";
              mountOptions = ["compress=zstd" "noatime"];
            };
            "/home" = {
              mountpoint = "/home";
              mountOptions = ["compress=zstd" "noatime"];
            };
          };
        };
      };
    };
  };

  # ESP stays as it is today (not managed by disko).
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0C33-701A";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
