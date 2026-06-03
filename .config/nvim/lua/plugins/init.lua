return {
  -- UI & Theming
  require "plugins.ui.noice",
  require "plugins.ui.tmux-navigator",
  require "plugins.ui.nvim-tree",
  require "plugins.ui.image",
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
  -- require "plugins.editing.render-markdown",
  require "plugins.editing.conform",
  require "plugins.editing.mason-conform",
  require "plugins.editing.latex",
  require "plugins.editing.typst",
  { "echasnovski/mini.surround", lazy = false, opts = { n_lines = 500 } },
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
  require "plugins.tools.jupyter",
  require "plugins.tools.obsidian",
  require "plugins.tools.yazi",
  require "plugins.tools.markview",
  require "plugins.tools.rsync",
  -- require "plugins.tools.strudel",
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewRefresh" },
  },

  -- AI
  require "plugins.ai.avante",
  require "plugins.ai.mcphub-config",

  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
    ft = { "cs", "vb" },
  },
}
