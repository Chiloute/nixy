{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}:
{
  home = {
    packages =
      with pkgs-unstable;
      [
        go
        claude-code
        typst
      ]
      ++ (with pkgs; [
        cargo
        rustc
        nodejs
        air
        duckdb
        python3
        jq
        nix-prefetch-github
        rsync
        texliveFull # full TeX Live: lualatex, latexmk, every CTAN package
      ]);

    sessionPath = [ "$HOME/.local/share/go/bin" ];
    sessionVariables = {
      GOPATH = "$HOME/.local/share/go";
    };
  };
}
