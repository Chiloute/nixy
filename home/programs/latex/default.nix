{pkgs, ...}: {
  home.packages = with pkgs; [
    texlive.combined.scheme-full
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
