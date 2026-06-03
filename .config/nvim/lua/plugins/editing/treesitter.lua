-- nvim-treesitter `main` branch (the old `master` API is archived/frozen).
-- NvChad v2.5 core already drives the main-branch flow for us:
--   * highlighting: a global `FileType *` autocmd calls `vim.treesitter.start()`
--   * installing:   `build = ":TSUpdate | TSInstallAll"` -> `require("nvim-treesitter").install(opts.ensure_installed)`
-- Folds are set natively in `lua/options.lua` (vim.treesitter.foldexpr).
-- So here we only (1) extend the parser list and (2) own the textobjects setup.
-- Parsers we want. The `main` branch installs these (parser + queries) into
-- the install_dir (stdpath("data")/site) via `require("nvim-treesitter").install`.
-- REQUIRES the `tree-sitter` CLI on PATH (pacman -S tree-sitter-cli); the main
-- branch shells out to `tree-sitter build` to compile grammars.
local ensure_installed = {
  -- NvChad base also adds: lua, luadoc, printf, vim, vimdoc
  -- Web
  "html",
  "css",
  "typescript",
  "tsx",
  "javascript",
  "toml",
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
  -- Markdown + injected code blocks (replaces the old info-string directive patch)
  "markdown",
  "markdown_inline",
  -- Required by noice.nvim (cmdline/message highlighting)
  "regex",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- Drive the install ourselves: NvChad's :TSInstallAll reads `spec.opts` only
    -- when it is a table, but merged opts are a function here, so it no-ops.
    -- `build` runs on install/update (:Lazy build/sync); :wait() makes it sync.
    build = function()
      require("nvim-treesitter").install(ensure_installed):wait(300000)
    end,
    -- Keep an opts function so lazy still calls require("nvim-treesitter").setup()
    -- (registers install_dir on runtimepath so installed queries are found) and
    -- so NvChad's autocmd-based install path has the list too.
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, ensure_installed)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require "nvim-treesitter-textobjects.select"
      local move = require "nvim-treesitter-textobjects.move"
      local swap = require "nvim-treesitter-textobjects.swap"
      local map = vim.keymap.set

      -- Select (visual + operator-pending)
      local selects = {
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
      }
      for lhs, capture in pairs(selects) do
        map({ "x", "o" }, lhs, function()
          select.select_textobject(capture, "textobjects")
        end, { desc = "TS select " .. capture })
      end

      -- Move to next/previous start
      local goto_next = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]p"] = "@parameter.outer",
      }
      for lhs, capture in pairs(goto_next) do
        map({ "n", "x", "o" }, lhs, function()
          move.goto_next_start(capture, "textobjects")
        end, { desc = "TS next " .. capture })
      end

      local goto_prev = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[p"] = "@parameter.outer",
      }
      for lhs, capture in pairs(goto_prev) do
        map({ "n", "x", "o" }, lhs, function()
          move.goto_previous_start(capture, "textobjects")
        end, { desc = "TS prev " .. capture })
      end

      -- Swap parameters
      map("n", "<leader>p", function()
        swap.swap_next "@parameter.inner"
      end, { desc = "TS swap next parameter" })
      map("n", "<leader>P", function()
        swap.swap_previous "@parameter.inner"
      end, { desc = "TS swap prev parameter" })
    end,
  },
}
