return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    ensure_installed = {
      -- Defaults
      "vim",
      "vimdoc",
      -- Web
      "html",
      "css",
      "typescript",
      "javascript",
      "toml",
      -- Lua
      "lua",
      -- Shell
      "bash",
      "fish",
      -- Go
      "go",
      "gomod",
      "gosum",
      "gotmpl",
      "gowork",
      -- Other
      "c_sharp",
      "python",
      "rust",
      "terraform",
    },
    highlight = {
      enable = true,
      use_languagetree = true,
    },
    -- indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["ap"] = "@parameter.outer",
          ["ip"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]p"] = "@parameter.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[p"] = "@parameter.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>p"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>P"] = "@parameter.inner",
        },
      },
    },
  },
  build = ":TSUpdate",
}
