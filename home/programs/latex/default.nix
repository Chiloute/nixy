{
  pkgs,
  lib,
  ...
}: let
  tex = pkgs.texlive.combined.scheme-full;
in {
  home.packages = [
    tex
  ];

  programs.zathura = {
    enable = true;
    options = {
      # SyncTeX : clic dans le PDF = curseur dans Neovim
      synctex = true;
      synctex-editor-command = "nvim --server /tmp/nvim.sock --remote-send '<cmd>call vimtex#view#reverse_goto(%{line}, \"%{input}\")<cr>'";
      # Confort visuel
      recolor = true; # mode "sombre" selon le thème
      recolor-keephue = true;
      adjust-open = "best-fit";
      scroll-step = 100;
    };
  };

  home.file.".latexmkrc".text = ''
    $pdf_previewer = 'zathura %O %S';
    $pdf_mode = 4;
  '';

  # Alias pratiques
  programs.zsh.shellAliases = {
    lmk = "latexmk -lualatex -pvc"; # compile + watch (lualatex, requis par fontspec)
    lmkx = "latexmk -xelatex -pvc"; # avec XeLaTeX
    lmkc = "latexmk -C"; # clean
  };

  # Régénération du cache de polices luaotfload (fontspec/lualatex).
  #
  # Sur NixOS, le chemin /nix/store d'une police change à chaque mise à jour
  # du paquet qui la fournit (ex: corefonts -> Arial). luaotfload garde en
  # cache l'ANCIEN chemin absolu ; au moment d'embarquer la police dans le
  # PDF, lualatex ouvre un chemin disparu et échoue avec l'erreur fatale :
  #   ! error:  (file ) (type 2): cannot find file ''
  #
  # On régénère donc le cache, mais UNIQUEMENT quand l'ensemble des polices
  # concernées change (comparaison à un marqueur) -> aucun surcoût sur un
  # rebuild normal.
  home.activation.luaotfloadCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    marker="''${XDG_CACHE_HOME:-$HOME/.cache}/luaotfload-fontset"
    current="${pkgs.corefonts}:${tex}"
    if [ "$(cat "$marker" 2>/dev/null || true)" != "$current" ]; then
      export PATH="${tex}/bin:$PATH"
      texmfvar="$(kpsewhich -var-value TEXMFVAR 2>/dev/null || echo "$HOME/.texlive2025/texmf-var")"
      rm -rf "$texmfvar/luatex-cache/generic/names" "$texmfvar/luatex-cache/generic/fonts"
      luaotfload-tool --update --force >/dev/null 2>&1 || true
      mkdir -p "$(dirname "$marker")"
      printf '%s' "$current" > "$marker"
    fi
  '';
}
