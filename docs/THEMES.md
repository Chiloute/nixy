# Themes

A theme is a NixOS module in `themes/` that sets the colors, fonts, cursor, wallpaper and layout values used by Hyprland, Waybar and the other apps through Stylix.

| File | Used by |
|---|---|
| `themes/darkviolet.nix` | `hosts/laptop` |
| `themes/nixy.nix` | `hosts/server` |
| `themes/rose-pine.nix` | no host |
| `themes/zen.nix` | no host |

## Select a theme

Change the import in your host's `variables.nix`:

```nix
imports = [
  # Choose your theme here:
  ../../themes/darkviolet.nix
];
```

Rebuild with `sudo nixos-rebuild switch --flake ~/.config/nixos#yourhostname`.

## Create a theme

1. Copy an existing theme, for example `themes/nixy.nix`, to `themes/mytheme.nix`.
2. Edit the two parts of the module:

   | Part | Keys |
   |---|---|
   | `options.theme` default | `rounding`, `bar-height`, `gaps-in`, `gaps-out`, `active-opacity`, `inactive-opacity`, `blur`, `border-size`, `animation-speed` |
   | `config.stylix` | `base16Scheme` (`base00` to `base0F`), `cursor`, `fonts`, `polarity`, `image` (wallpaper) |

   `darkviolet.nix`, `rose-pine.nix` and `zen.nix` also set `fetch` and `textColorOnWallpaper`; `nixy.nix` does not. Copy from a theme that has the keys you need.
3. Point `variables.nix` at the new file.

Wallpapers are fetched with `pkgs.fetchurl` from [awesome-wallpapers](https://github.com/anotherhadi/awesome-wallpapers). Changing the URL requires a new `sha256`; build once with an empty hash and copy the value from the error.
