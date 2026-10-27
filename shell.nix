{
  pkgs,
  gitHooksLib,
}: let
  hooks = gitHooksLib.run {
    src = ./.;
    hooks = {
      inject-exec = {
        enable = true;
        name = "inject-exec";
        entry = "python3 .github/scripts/inject-exec.py README.md";
        language = "system";
        files = "(README\\.md)";
        pass_filenames = false;
      };

      doctoc = {
        enable = true;
        name = "doctoc";
        entry = "doctoc --notitle README.md";
        language = "system";
        files = "(README\\.md)";
        pass_filenames = false;
      };

      # Hyprland runs the Lua config: hyprlang-only calls fail at runtime, not at build.
      no-hyprlang = {
        enable = true;
        name = "no-hyprlang";
        entry = "hyprctl (keyword|dispatch [a-z])|exec-once =|settings\\.(exec-once|bind)";
        language = "pygrep";
        files = "\\.nix$";
        excludes = ["shell\\.nix"];
      };
    };
  };
in
  pkgs.mkShell {
    packages = with pkgs;
      [
        doctoc
        python3
      ]
      ++ hooks.enabledPackages;

    shellHook = hooks.shellHook;
  }
