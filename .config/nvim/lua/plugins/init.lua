return {
  -- UI & Theming
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
      require("scrollbar").setup()
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
  -- Editing & Syntax
  require "plugins.editing.telescope",
  require "plugins.editing.treesitter",
  require "plugins.editing.render-markdown",
  require "plugins.editing.conform",
  require "plugins.editing.mason-conform",
  { "echasnovski/mini.surround", lazy = false, opts = {} },
  { "echasnovski/mini.align", lazy = false, opts = {} },
  { "echasnovski/mini.splitjoin", lazy = false, opts = {} },
  { "echasnovski/mini.comment", lazy = false, opts = {} },
  { "echasnovski/mini.ai", lazy = false, opts = {} },
  -- { "echasnovski/mini.notify", lazy = false, opts = {} },
  -- LSP & Completion
  require "plugins.lsp.lspconfig",
  require "plugins.linting.linting",
  require "plugins.dap.core",
  require "plugins.dap.csharp",
  require "plugins.dap.go",
  require "plugins.dap.python",
  require "plugins.dap.lua",
  -- Tools
  require "plugins.tools.resession",
  require "plugins.tools.toggleterm",
  require "plugins.tools.leetcode",
  require "plugins.tools.overseer.overseer",
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewRefresh" },
  },

  -- AI
  require "plugins.ai.avante",
  require "plugins.ai.mcphub",

  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
    ft = { "cs", "vb" },
  },
}
