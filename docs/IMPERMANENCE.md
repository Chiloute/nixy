# Impermanence migration (laptop `corava`)

`/` becomes a tmpfs that is wiped on every boot. Only `/nix`, `/persist` and `/home` (btrfs subvolumes on LUKS) survive.

Files:
- `hosts/laptop/disko.nix`: formats **only** `nvme0n1p5` (partlabel `root`). It never touches Windows or the ESP.
- `hosts/laptop/persistence.nix`: what is kept in `/persist`, plus the user password read from `/persist/secrets/<user>.hash`.

Neither file is **imported** yet. Importing them on the current (ext4) system would leave it unbootable.

> [!CAUTION]
> Step 3 wipes the whole NixOS partition. Your backup is the only way back.

## 1. Backup (to the Crucial X8)

```sh
B=/run/media/chiloute/X8/corava-backup
sudo rsync -aHAX --info=progress2 /home/ "$B/home/"
sudo rsync -aHAXR /var/lib/{sbctl,fprint,bluetooth,NetworkManager,libvirt,fwupd,nixos} \
  /etc/NetworkManager/system-connections /etc/machine-id "$B/root/"
cp ~/.config/sops/age/keys.txt "$B/age-keys.txt"   # without it, no sops secret can be decrypted
```

Check that `$B/root/var/lib/sbctl/keys` and `$B/age-keys.txt` exist and are not empty.

## 2. Boot the NixOS ISO

- Secure Boot: disable it in the BIOS (the ISO is not signed with your keys). The enrolled keys stay in the firmware.
- Check the target: `lsblk -o NAME,SIZE,FSTYPE,PARTLABEL` must show `nvme0n1p5  150G  crypto_LUKS  root`.

## 3. Format (wipes `nvme0n1p5`)

```sh
git clone <your repo> /tmp/nixos && cd /tmp/nixos && git switch review/2026-10
sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode destroy,format,mount hosts/laptop/disko.nix
sudo mkdir -p /mnt/boot && sudo mount /dev/nvme0n1p1 /mnt/boot
```

## 4. Restore state

```sh
B=/run/media/<iso-user>/X8/corava-backup
sudo rsync -aHAX "$B/home/" /mnt/home/
sudo rsync -aHAX "$B/root/" /mnt/persist/
sudo mkdir -p /mnt/var/lib && sudo cp -a "$B/root/var/lib/sbctl" /mnt/var/lib/   # nixos-install signs Limine with these keys

sudo mkdir -p /mnt/persist/secrets
mkpasswd -m yescrypt | sudo tee /mnt/persist/secrets/chiloute.hash >/dev/null
sudo chmod 600 /mnt/persist/secrets/chiloute.hash
```

## 5. Adapt the config (in `/mnt/home/chiloute/.config/nixos`)

```sh
cd /mnt/home/chiloute/.config/nixos
sudo nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > hosts/laptop/hardware-configuration.nix
```

In `hosts/laptop/configuration.nix`:
- add `./disko.nix` and `./persistence.nix` to the imports;
- remove the `boot.initrd.luks.devices."luks-61744d98-…"` block (disko declares `crypted` with the same options).

```sh
nix flake check
sudo nixos-install --flake .#corava --no-root-passwd
```

## 6. First boot

- Re-enable Secure Boot in the BIOS.
- Checks:
  - `findmnt /` → `tmpfs`
  - `sudo sbctl verify`: everything is signed
  - `fprintd-verify`, Wi-Fi and Bluetooth are recognised
  - `systemctl --user status sops-nix` OK
- Reboot a second time and check that a file created in `/root` is gone and that `/home` is intact.
- Commit (on the branch): `hardware-configuration.nix` and `configuration.nix`.
