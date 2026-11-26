{pkgs, ...}: {
  vim = {
    extraPlugins.vimtex.package = pkgs.vimPlugins.vimtex;

    globals = {
      # zathura is sandboxed without D-Bus and runs on Wayland (no xdotool): no synctex, plain open + auto-reload
      vimtex_view_method = "zathura_simple";
      vimtex_view_zathura_use_synctex = 0; # --synctex-forward needs D-Bus: sandboxed zathura exits at once with it

      vimtex_view_automatic = 1;
      vimtex_compiler_method = "latexmk";
      vimtex_compiler_latexmk = {
        aux_dir = ".latexmk";
        out_dir = ".latexmk";
        continuous = 1; # latexmk -pvc: rebuilds on every save
        options = [
          "-verbose"
          "-file-line-error"
          "-synctex=1"
          "-interaction=nonstopmode"
        ];
      };
      # LuaLaTeX by default (modern engine: fontspec, unicode-math); "% !TEX program = ..." still overrides it
      vimtex_compiler_latexmk_engines._ = "-lualatex";
    };

    languages.tex.enable = true; # treesitter + texlab LSP

    keymaps = [
      {
        key = "<leader>Ll";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexCompile<cr>";
        desc = "LaTeX: toggle compile (watch)";
      }
      {
        key = "<leader>Lv";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexView<cr>";
        desc = "LaTeX: open Zathura";
      }
      {
        key = "<leader>Lk";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexStop<cr>";
        desc = "LaTeX: stop compile";
      }
      {
        key = "<leader>Lc";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexClean<cr>";
        desc = "LaTeX: clean build";
      }
      {
        key = "<leader>Le";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexErrors<cr>";
        desc = "LaTeX: show errors";
      }
      {
        key = "<leader>Lt";
        mode = "n";
        silent = true;
        action = "<cmd>VimtexTocToggle<cr>";
        desc = "LaTeX: table of contents";
      }
    ];

    # First save of a .tex buffer starts latexmk in watch mode; it then rebuilds on every later save
    luaConfigRC.vimtex-autocompile = ''
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*.tex',
        callback = function()
          -- VimtexCompile takes args, so it cannot sit inside a `| endif` one-liner
          if vim.b.vimtex and vim.fn.eval('!b:vimtex.compiler.is_running()') == 1 then
            vim.cmd('VimtexCompile')
          end
        end,
      })
    '';
  };
}
