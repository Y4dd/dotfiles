return {
  -- UI & Theming
  -- require "plugins.ui.dressing",
  require "plugins.ui.noice",
  require "plugins.ui.tmux-navigator",
  require "plugins.ui.nvim-tree",
  {
    "nvzone/minty",
    cmd = { "Shades", "Hue" },
  },
  {
    "petertriho/nvim-scrollbar",
    lazy = false,
    config = function()
      require("scrollbar").setup {}
      require("scrollbar.handlers.gitsigns").setup {}
    end,
  },
  -- {
  --   "nanozuki/tabby.nvim",
  --   event = "VimEnter",
  --   dependencies = "nvim-tree/nvim-web-devicons",
  --   config = function()
  --     require "configs.tabby"
  --   end,
  -- },
  --
  --
  -- Editing & Syntax
  require "plugins.editing.telescope",
  require "plugins.editing.treesitter",
  require "plugins.editing.render-markdown",
  require "plugins.editing.conform",
  require "plugins.editing.mason-conform",
  { "echasnovski/mini.surround", lazy = false, opts = {} },
  { "echasnovski/mini.align", lazy = false, opts = {} },
  { "echasnovski/mini.splitjoin", lazy = false, opts = {} },
  -- { "echasnovski/mini.notify", lazy = false, opts = {} },
  -- LSP & Completion
  require "plugins.lsp.lspconfig",
  require "plugins.lsp.mason-lspconfig",
  require "plugins.linting.linting",
  -- require "plugins.dap.core",
  -- require "plugins.dap.go",
  -- require "plugins.dap.python",
  -- require "plugins.dap.lua",
  -- Tools
  require "plugins.tools.resession",
  require "plugins.tools.toggleterm",
  require "plugins.tools.leetcode",
  require "plugins.tools.overseer.overseer",
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewRefresh" },
  },
  {
    "ahmedkhalf/project.nvim",
  },

  -- AI
  require "plugins.ai.avante",
  require "plugins.ai.mcphub",

  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
    ft = { "cs", "vb" },
  },
  -- Lint
  -- {
  --   "mfussenegger/nvim-lint",
  --   event = { "BufReadPre", "BufNewFile" },
  --   config = function()
  --     require "configs.lint"
  --   end,
  -- },
  -- {
  --   "rshkarin/mason-nvim-lint",
  --   event = "VeryLazy",
  --   dependencies = { "nvim-lint" },
  --   config = function()
  --     require "configs.mason-lint"
  --   end,
}
