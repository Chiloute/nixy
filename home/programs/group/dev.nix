{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  home = {
    packages = with pkgs-unstable;
      [
        go
        claude-code
      ]
      ++ (with pkgs; [
        nodejs
        air
        duckdb
        python3
        jq
        nix-prefetch-github
        rsync
      ]);

    sessionPath = ["$HOME/.local/share/go/bin"];
    sessionVariables.GOPATH = "$HOME/.local/share/go";
  };
}
