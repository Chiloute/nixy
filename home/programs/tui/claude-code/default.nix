# Claude Code sandboxed with nixpak (from anotherhadi/nixy, modules/programs/dev/claude-code.nix)
# `claude`        : network, but only sees the project it is started in and its own state.
#                   Secrets (~/.ssh, ~/.gnupg, gh...) are hidden: no push nor signed commits from inside.
# `claude-unsafe` : the plain package, for what needs your keys (git push, signed commits).
{
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  mkSandbox = import ../../../lib/sandbox.nix {inherit inputs pkgs;};

  sandboxed = mkSandbox.wrap {
    package = pkgs-unstable.claude-code;
    config = {sloth, ...}: let
      home = sloth.concat' sloth.homeDir;
    in {
      bubblewrap = {
        network = true;
        bind.rw = [
          (sloth.env "CLAUDE_SANDBOX_DIR") # set by the wrapper below
          (home "/.claude")
          (home "/.claude.json")
          (home "/.cache/go-build")
          (home "/.local/share/go") # GOPATH (module cache)
        ];
        bind.ro = [
          "/bin/sh" # hooks are spawned through /bin/sh, which nixpak doesn't bind
          "/usr/bin/env" # #!/usr/bin/env shebangs of hook scripts
          (home "/.config/git")
          (home "/.agents") # skills symlinked from ~/.claude/skills (security-audit, find-skills)
          "/nix/var/nix/daemon-socket" # nix build/eval through the daemon (user isn't trusted)
        ];
        tmpfs = ["/tmp"];
        env = {
          TMPDIR = "/tmp";
          NIX_REMOTE = "daemon";
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"; # No telemetry, error reporting nor autoupdater
        };
      };
    };
  };

  claude = pkgs.writeShellScriptBin "claude" ''
    mkdir -p "$HOME/.claude"
    [ -e "$HOME/.claude.json" ] || echo '{}' > "$HOME/.claude.json"

    # Project = enclosing git repo (so .git is visible from a subdir), else the current dir
    CLAUDE_SANDBOX_DIR=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd -P)
    case "$CLAUDE_SANDBOX_DIR" in
      / | "$HOME")
        echo "claude: refusing to expose $CLAUDE_SANDBOX_DIR, start it from a project dir" >&2
        exit 1
        ;;
    esac
    export CLAUDE_SANDBOX_DIR
    exec ${sandboxed}/bin/claude "$@"
  '';

  claude-unsafe = pkgs.writeShellScriptBin "claude-unsafe" ''
    export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
    exec ${pkgs-unstable.claude-code}/bin/claude "$@"
  '';
in {
  # hiPrio: dev.nix also installs the plain claude-code, whose bin/claude would collide
  home.packages = [(lib.hiPrio claude) claude-unsafe];
}
