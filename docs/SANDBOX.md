# Sandboxes

Desktop apps and Claude Code run inside [nixpak](https://github.com/nixpak/nixpak) sandboxes (bubblewrap). `home/lib/sandbox.nix` provides the wrapper; each app declares what it may see.

Sandboxed apps: Discord, LibreOffice, Obsidian, Pinta, Signal, VLC, Zathura (`home/programs/gui/`) and Claude Code (`home/programs/tui/claude-code/`).

## Defaults

| Setting | Default | Change with |
|---|---|---|
| Network | off | `bubblewrap.network = true` |
| D-Bus | off | `dbus.enable = true` |
| `/etc`, `/run/current-system` | read-only | |
| Wayland, GPU, portals | off | `gui = true` |
| `$HOME` | not mounted | `home = "ro" \| "rw" \| "cwd"` |
| Parent process exits | sandbox dies with it | |

These paths are replaced by an empty tmpfs even when `$HOME` is mounted: `~/.ssh`, `~/.gnupg`, `~/.local/share/keyrings`, `~/.config/sops`, `~/.config/gh`, `~/.mozilla`, `~/.config/net.imput.helium`, `~/.pki`, `~/.local/share/password-store`. With `home = "rw"` or `"cwd"`, `~/.config/nixos`, `~/.local/share/go/bin` and `~/.local/share/applications` are mounted read-only.

## Sandbox a new app

```nix
{inputs, pkgs, ...}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = import ../../lib/in-home.nix;

  vlc = mkSandbox.wrap {
    package = pkgs.vlc;
    gui = true;
    config = {sloth, ...}: {
      flatpak = {
        appId = "org.videolan.VLC";
        desktopFile = "vlc.desktop";
      };
      bubblewrap = {
        bind.ro = inHome sloth ["Documents" "Downloads" "Music" "Videos"];
        bind.rw = inHome sloth [".config/vlc" ".local/share/vlc"];
        sockets = {pipewire = true; pulse = true;};
      };
    };
  };
in {
  home.packages = [vlc];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = ["d %h/.config/vlc 0700 - - -"];
}
```

A bind source that does not exist makes the sandbox fail to start, hence the `tmpfiles` rule. See `home/programs/gui/vlc.nix` for the full file.

## Claude Code

`home/programs/tui/claude-code/default.nix` installs two commands:

| Command | Network | Sees | Cannot |
|---|---|---|---|
| `claude` | yes | the current git repository (or directory), `~/.claude`, `~/.claude.json`, `~/.config/git` (read-only), the Go caches | read SSH, GPG or `gh` credentials; `git push` or sign commits |
| `claude-unsafe` | yes | everything your user sees | |

`claude` refuses to start from `/` or from `$HOME`. It sets `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` (no telemetry or autoupdater), and reaches the Nix daemon socket so `nix build` works from inside. `~/.agents` is mounted read-only so skills linked from `~/.claude/skills` resolve.

Use `claude-unsafe` for steps that need your keys, such as `git push` or signed commits.

## Known limits

- `sockets.wayland` gives the app the raw Wayland socket, including privileged protocols (screencopy, virtual keyboard, data-control). `home/lib/sandbox.nix` carries a TODO for filtering them.
- `flake.nix` pins nixpak to one revision because `home/lib/sandbox.nix` patches its sources (terminal foreground for TUI apps, missing tmpfs targets, `/etc/hosts` symlinks). Bumping the input can break those patches.
