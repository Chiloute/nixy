# Contributing to Nixy

Bug fixes, new themes and new modules are welcome. Check the issues for open work.

1. Read [How to get faster PR reviews](https://github.com/kubernetes/community/blob/master/contributors/guide/pull-requests.md#best-practices-for-faster-reviews) from Kubernetes (skip steps 0 and 1).
2. Fork the [Nixy repository](https://github.com/anotherhadi/nixy) and create a branch.
3. Enter the dev shell so the git hooks are installed:

   ```sh
   nix develop
   ```

4. Make your change, then format and check it:

   ```sh
   nix fmt
   nix flake check
   ```

5. Open a pull request against `main`.

## Things that break contributions

> [!IMPORTANT]
> Don't push your host's folder. `hosts/<your-host>/` holds your hostname, user name, git identity and sops secrets.

- `README.md` is generated. Edit `.github/assets/README_template.md`; the `update-readme` workflow rebuilds `README.md` when the template changes.
- The `no-hyprlang` hook rejects `hyprctl keyword`, `hyprctl dispatch <word>`, `exec-once =` and `settings.bind` in `.nix` files, because Hyprland runs the Lua config. See [HYPRLAND](HYPRLAND.md).
- Nix flakes ignore untracked files. Run `git add` on new files before `nix flake check`.
