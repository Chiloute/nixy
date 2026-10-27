# Hyprland configuration (Lua)

Hyprland is configured in Lua. Home Manager generates `~/.config/hypr/hyprland.lua` from the Nix modules in `home/system/hyprland/`; no `hyprland.conf` is produced.

## Where things go

| What | How | File |
|---|---|---|
| Options (`general`, `decoration`, `input`…) | `settings.config = { … }`, rendered as `hl.config({ … })` | `default.nix` |
| Environment variables | `settings.env = [ { _args = [ "NAME" "value" ]; } ]` | `default.nix` |
| Monitors and workspaces | `settings.monitor` / `settings.workspace_rule` | `hosts/<host>/home.nix` |
| Window and layer rules | `settings.window_rule` / `settings.layer_rule` | `default.nix` |
| Curves and animations | `settings.curve` / `settings.animation` | `animations.nix` |
| Commands run at startup | `settings.on = [ (hl.onStart "cmd") ]` | any module |
| Keybindings | Lua in `extraConfig`, with `exec "cmd"` for commands | `bindings.nix` |

`hl.onStart` and `exec` come from `home/system/hyprland/lua.nix`:

```nix
let
  hl = import ../hyprland/lua.nix {inherit lib;};
in {
  wayland.windowManager.hyprland.settings.on = [(hl.onStart "waybar")];
}
```

Settings are emitted in alphabetical order. `importantPrefixes = ["env" "curve"]` in `default.nix` moves environment variables and curves before the calls that depend on them.

## Calling Hyprland from scripts

`hyprctl` takes Lua with this config:

| Hyprlang | Lua |
|---|---|
| `hyprctl dispatch exit` | `hyprctl dispatch 'hl.dsp.exit()'` |
| `hyprctl dispatch workspace e+1` | `hyprctl dispatch 'hl.dsp.focus({ workspace = "e+1" })'` |
| `hyprctl keyword general:gaps_in 0` | `hyprctl eval 'hl.config({ general = { gaps_in = 0 } })'` |

In a `.desktop` `Exec` key, quote the Lua argument with double quotes.

## Safeguards

- The build runs `Hyprland --verify-config` on the generated file, so `nixos-rebuild` fails on an unknown option, rule field or dispatcher argument.
- The `no-hyprlang` pre-commit hook (`shell.nix`) rejects `hyprctl keyword`, old-style `hyprctl dispatch`, `exec-once` and `settings.bind`.

## Not migrated

hyprlock, hypridle and hyprpaper have no Lua support yet (checked up to hyprlock 0.9.6, hypridle 0.1.8 and hyprpaper 0.8.4) and keep their own `.conf` files. Calls they make into Hyprland use the Lua syntax.
