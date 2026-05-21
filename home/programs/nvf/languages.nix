{
  lib,
  pkgs,
  ...
}: {
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
        virtual_text = {
          format =
            lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(diagnostic)
                return string.format("%s", diagnostic.message)
              end
            '';
        };
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
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        typescript
      ];
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
      formatOnSave = true;
      mappings.format = null;
      inlayHints.enable = true;
      null-ls.enable = true;
      servers.nixd.settings.nil.nix.autoArchive = true;
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
          breadcrumbs.enable = false;
        };
      };
    };
    languages = {
      enableDAP = true;
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
      svelte = {
        enable = true;
        format.enable = false;
      };
      html.enable = true;
      bash.enable = true;
      nix.enable = true;
      lua.enable = true;
    };
    formatter = {
      conform-nvim = {
        enable = true;
        setupOpts.format_after_save = null;
      };
    };
  };
}
