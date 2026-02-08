{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # lang servers
    pkgs.vscode-langservers-extracted
    pkgs.elixir
    pkgs.elixir-ls
    pkgs.typescript
    pkgs.nodePackages.typescript-language-server
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities = require('cmp_nvim_lsp').default_capabilities()

          vim.lsp.config.html = { capabilities = capabilities }
          vim.lsp.config.elixirls = {
            cmd = {"${pkgs.elixir-ls}/bin/elixir-ls"},
            capabilities = capabilities
          }
          vim.lsp.config.ts_ls = { capabilities = capabilities }
          vim.lsp.enable({'html', 'elixirls', 'ts_ls'})
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-cmdline
      cmp-path
      nvim-cmp
      luasnip
      cmp_luasnip
      fidget-nvim
      telescope-nvim
      nvim-web-devicons
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require("nvim-treesitter.configs").setup({
            auto_install = false,
            highlight = {
              enable = true,
              disable = { }
            },
          })
        '';
      }
      telescope-zoxide
      vim-tmux-navigator
      ansible-vim
      vim-nix
      {
        plugin = nord-nvim;
        type = "lua";
        config = ''
          vim.cmd[[colorscheme nord]]
        '';
      }
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          local conform = require("conform")

          conform.setup({
            formatters_by_ft = {
              javascript = { "prettier" },
              typescript = { "prettier" },
              javascriptreact = { "prettier" },
              typescriptreact = { "prettier" },
              svelte = { "prettier" },
              css = { "prettier" },
              html = { "prettier" },
              json = { "prettier" },
              yaml = { "prettier" },
              markdown = { "prettier" },
              graphql = { "prettier" },
              lua = { "stylua" },
              python = { "isort", "black" },
            },
            format_on_save = {
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            },
          })

          vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            })
          end, { desc = "Format file or range (in visual mode)" })
        '';
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require("Comment").setup()
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup()
        '';
      }
      lualine-lsp-progress
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require("nvim-tree").setup()
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          vim.o.timeout = true
          vim.o.timeoutlen = 500
          require("which-key").setup()
        '';
      }
      {
        plugin = nvim-surround;
        type = "lua";
        config = ''
          require("nvim-surround").setup()
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require("nvim-autopairs").setup()
        '';
      }
    ];
    extraConfig = ''
      :luafile ~/.config/nvim/options.lua
      :luafile ~/.config/nvim/keymaps.lua
      :luafile ~/.config/nvim/cmp.lua
    '';
  };
  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };
}
