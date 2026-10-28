# Security

What is hardened on each host and where to change it. Nothing here replaces reading the module itself.

## Laptop (`corava`)

| Layer | File | Behavior |
|---|---|---|
| Kernel sysctl and boot parameters | `nixos/kernel-hardening.nix` | Restricted `dmesg`/kernel pointers, BPF JIT hardening, `ptrace_scope = 1`, `kexec` disabled, `sysrq = 4`, zeroed allocations (`init_on_alloc`, `init_on_free`), `slab_nomerge`. Unused protocols (`dccp`, `sctp`, `rds`, `tipc`) and FireWire modules are blacklisted. `sudo` is limited to the `wheel` group |
| USB devices | `hosts/laptop/usbguard.nix` | `implicitPolicyTarget = "block"`; only the listed devices are allowed. Only `root` may use the IPC |
| YubiKey | `nixos/yubikey.nix` | `pam_u2f` with `control = "sufficient"` for `sudo`, `login` and `polkit-1`; not for `hyprlock` |
| Fingerprint | `nixos/fprintd.nix` | Reader of the X1 Carbon Gen 12; password fallback; not for `hyprlock` |
| Desktop apps | `home/lib/sandbox.nix` | nixpak sandboxes, see [SANDBOX](SANDBOX.md) |
| Secrets | `hosts/*/secrets/` | sops-nix, age key in `~/.config/sops/age/keys.txt` |

`kernel-hardening.nix` leaves out `lockKernelModules` (breaks hot-plugged modules) and `protectKernelImage` (breaks hibernation). Debugging another running process (gdb attach, profilers) needs `sudo` because of `ptrace_scope = 1`.

### Register the YubiKey

```sh
mkdir -p ~/.config/Yubico && pamu2fcfg > ~/.config/Yubico/u2f_keys
```

Touch the key when it blinks. Until the file exists, PAM skips the key and asks for the password or fingerprint. Enroll a finger with `fprintd-enroll`, test with `fprintd-verify`.

### Allow a new USB device

1. Plug the device in.
2. Run `sudo usbguard generate-policy` and copy the line for the device.
3. Add it to `services.usbguard.rules` in `hosts/laptop/usbguard.nix`.
4. Rebuild. The dock, the Crucial X8, the SanDisk drive and the YubiKey are matched by vendor and product ID (`17ef:*`, `0634:5602`, `0781:5591`, `1050:0407`), the internal devices by hash.

## Server

Applies to `cora` (see [SERVER](SERVER.md)).

| Layer | File | Behavior |
|---|---|---|
| SSH | `server-modules/ssh.nix` | Key-only, no root login, `AllowUsers` limited to the main user, 3 tries, 20 s grace time, no forwarding, post-quantum key exchange first (`mlkem768x25519-sha256`) |
| Firewall | `server-modules/firewall.nix` | Ping dropped, `FORWARD` policy `DROP` |
| fail2ban | `server-modules/fail2ban.nix` | Ban after 5 failures for 24 h, doubling per ban up to 168 h across all jails. `127.0.0.1`, `::1` and `192.168.1.0/24` are ignored |
| ClamAV | `server-modules/clamav.nix` | `freshclam` updates, full scan at 03:00 and 15:00 as a sandboxed `systemd` unit (read-only filesystem, no network, one capability). A failed or positive scan logs at `user.crit` |
| Kernel | `server-modules/kernel-hardening.nix` | Same approach as the laptop |
| Containers | `server-modules/mk-container.nix` | Private networks, LAN and inter-container traffic dropped |

Connections through the Cloudflare Tunnel reach `sshd` from `127.0.0.1`, which fail2ban ignores. Access control for the tunnel hostnames is configured in Cloudflare, not in this repository.

## Audit notes

`SECURITY-REMEDIATION-PLAN.md` (French) is an audit of commit `0801c344` dated 2026-10-19. Checked against the current tree, these findings are fixed: `nixos/yubikey.nix` uses `pam_u2f`, `firewall.nix` sets the `FORWARD` policy, `clamav.nix` has systemd hardening, Gitea `ALLOWED_DOMAINS` no longer has the `*gitlab.com` wildcard, the `arr.nix` secret is `0400`, and the CI workflow pins its actions and the Go tool. The plan's checklist was not updated.

Still true: tunnelled SSH is invisible to fail2ban (see above), and `.github/scripts/inject-exec.py` runs the commands of `<!-- exec: -->` comments with `shell=True`.

TODO: re-check the USBGuard rules for removable media against the current code.
