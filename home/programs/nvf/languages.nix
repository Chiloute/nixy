{...}: {
  vim = {
    extraPlugins = {
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
      };
    };
    diagnostics = {
      enable = true;
      config = {
        signs = {
          text = {
            "vim.diagnostic.severity.Error" = " ";
            "vim.diagnostic.severity.Warn" = " ";
            "vim.diagnostic.severity.Hint" = " ";
            "vim.diagnostic.severity.Info" = " ";
          };
        };
        underline = true;
        update_in_insert = true;
        virtual_text = true;
      };
      nvim-lint = {
        enable = true;
      };
    };
    treesitter = {
      enable = true;
      autotagHtml = true;
      context.enable = true;
      highlight.enable = true;
    };
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
      # Ouvre le PDF automatiquement à la compilation
      "vimtex_view_automatic" = 1;
    };
    lsp = {
      enable = true;
      presets = {
        tailwindcss-language-server = {
          enable = true;
        };
      };
      trouble.enable = true;
      lspSignature.enable = true;
      lspconfig.enable = true;
      formatOnSave = false;
      mappings.format = null;
      inlayHints.enable = true;
      servers.nil.settings.nix.autoArchive = true;
      otter-nvim = {
        enable = true;
        setupOpts = {
          buffers.set_filetype = true;
          lsp = {
            diagnostic_update_event = [
              "BufWritePost"
              "InsertLeave"
            ];
          };
        };
      };
      lspkind.enable = true;
      lspsaga = {
        enable = true;
        setupOpts = {
          ui = {
            code_action = "";
          };
          lightbulb = {
            sign = false;
            virtual_text = true;
          };
          symbol_in_winbar.enable = false;
        };
      };
    };
    languages = {
      enableExtraDiagnostics = true;
      enableFormat = true;
      enableTreesitter = true;

      python = {
        enable = true;
        lsp = {
          enable = true;
          servers = ["pyright"];
        };
      };
      astro.enable = true;
      go.enable = true;
      markdown = {
        enable = true;
        format.type = ["prettierd"];
        extensions = {
          markview-nvim = {
            enable = true;
            setupOpts = {
              preview = {
                hybrid_modes = ["n"];
              };
            };
          };
        };
        extraDiagnostics.enable = true;
      };

      tex = {
        enable = true;
        lsp.enable = true;
      };
      rust.enable = true;
      typescript = {
        enable = true;
        extensions.ts-error-translator.enable = true;
      };
      css.enable = true;
      svelte.enable = true;
      html.enable = true;
      bash.enable = true;
      nix.enable = true;
      lua.enable = true;
    };
    formatter = {
      conform-nvim = {
        enable = true;
        setupOpts.format_on_save = {
          lsp_format = "fallback";
        };
      };
    };
  };
}
