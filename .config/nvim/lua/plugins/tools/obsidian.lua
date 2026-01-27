return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  -- ft = "markdown",
  event = {
    "BufReadPre " .. vim.fn.expand "~" .. "/vault/*.md",
    "BufNewFile " .. vim.fn.expand "~" .. "/vault/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
      {
        name = "academic",
        path = "~/vaults/academic",
      },
    },
  },
}
