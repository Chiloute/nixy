{pkgs, ...}: {
  home.packages = with pkgs; [
    (texlive.combine {
      inherit
        (texlive)
        scheme-medium
        latexmk
        minted
        upquote # dépendance minted
        fvextra # dépendance minted
        catchfile # dépendance minted
        titlesec # mise en forme des sections
        enumitem # personnalisation des listes
        biblatex
        biber
        fontawesome5
        microtype # typographie fine
        booktabs
        siunitx
        ;
    })
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
  '';

  # Alias pratiques
  programs.zsh.shellAliases = {
    lmk = "latexmk -pdf -pvc"; # compile + watch
    lmkx = "latexmk -xelatex -pvc"; # avec XeLaTeX
    lmkc = "latexmk -C"; # clean
  };
}
