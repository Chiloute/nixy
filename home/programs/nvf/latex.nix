{pkgs, ...}: {
  vim = {
    extraPlugins.vimtex.package = pkgs.vimPlugins.vimtex;

    globals = {
      "vimtex_view_method" = "zathura";
      "vimtex_compiler_method" = "latexmk";
      "vimtex_compiler_latexmk" = {
        aux_dir = ".latexmk";
        out_dir = ".latexmk";
        options = [
          "-verbose"
          "-file-line-error"
          "-synctex=1"
          "-interaction=nonstopmode"
        ];
      };
      # Moteur forcé : lualatex pour TOUTE compilation (requis par fontspec, unicode-math, etc.).
      # Toutes les clés pointent vers lualatex : même une ligne magique
      # "% !TEX program = xelatex/pdflatex" dans un document sera ignorée.
      "vimtex_compiler_latexmk_engines" = {
        "_" = "-lualatex";
        "pdflatex" = "-lualatex";
        "lualatex" = "-lualatex";
        "xelatex" = "-lualatex";
      };
      "vimtex_view_automatic" = 1;
    };

    languages.tex = {
      enable = true;
      lsp.enable = true;
    };

    keymaps = [
      {
        key = "<leader>Ll";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexCompile<cr>";
        desc = "LaTeX: compiler (watch)";
      }
      {
        key = "<leader>Lv";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexView<cr>";
        desc = "LaTeX: ouvrir Zathura";
      }
      {
        key = "<leader>Lk";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexStop<cr>";
        desc = "LaTeX: stopper la compilation";
      }
      {
        key = "<leader>Lc";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexClean<cr>";
        desc = "LaTeX: nettoyer le build";
      }
      {
        key = "<leader>Le";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexErrors<cr>";
        desc = "LaTeX: afficher les erreurs";
      }
      {
        key = "<leader>Lt";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexTocToggle<cr>";
        desc = "LaTeX: table des matières";
      }
    ];

    luaConfigRC.vimtex-clue = ''
      vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = function()
          table.insert(MiniClue.config.clues, { mode = 'n', keys = '<Leader>L', desc = '+vimtex' })
        end,
      })
    '';
  };
}
