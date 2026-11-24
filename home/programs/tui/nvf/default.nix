{
  config,
  lib,
  pkgs-unstable,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.nvf = {
    enable = true;
    settings = {
      # typst comes from unstable (>= 0.15), tinymist must match or recent @preview packages fail
      vim.lsp.servers.tinymist.cmd = lib.mkForce [(lib.getExe pkgs-unstable.tinymist)];
      vim.languages.typst.extensions.typst-preview-nvim.setupOpts.dependencies_bin = {
        tinymist = lib.getExe pkgs-unstable.tinymist;
        websocat = lib.getExe pkgs-unstable.websocat;
      };
      vim.luaConfigRC = lib.mkIf (config ? stylix && config.stylix.enable) {
        hl-overrides = let
          c = config.lib.stylix.colors;
        in ''
          local function apply_hl()
            vim.api.nvim_set_hl(0, "MiniStarterHeader",   { fg = "#${c.base0D}", bold = true })
            vim.api.nvim_set_hl(0, "SnacksPickerBorder",  { fg = "#${c.base0D}" })
            vim.api.nvim_set_hl(0, "SnacksPickerTitle",   { fg = "#${c.base0D}", bold = true })
          end
          apply_hl()
          vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = apply_hl })
        '';
      };
      imports = [
        ./options.nix
        ./languages.nix
        ./picker.nix
        ./snacks.nix
        ./keymaps.nix
        ./utils.nix
        ./mini.nix
      ];
    };
  };
}
