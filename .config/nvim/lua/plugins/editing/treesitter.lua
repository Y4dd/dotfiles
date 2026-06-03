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
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    -- nvim-treesitter is archived and its directive handlers break on nvim 0.12+:
    -- match[capture_id] now returns TSNode[] instead of a single TSNode, so
    -- calling get_node_text on the array hits a nil :range() method.
    -- Force-load query_predicates first so our override runs after theirs.
    require("nvim-treesitter.query_predicates")
    vim.treesitter.query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
      local nodes = match[pred[2]]
      if not nodes then return end
      local node = type(nodes[1]) ~= "nil" and nodes[1] or nodes
      if not node or type(node.range) ~= "function" then return end
      local alias = vim.treesitter.get_node_text(node, bufnr):lower()
      local lang = vim.filetype.match({ filename = "a." .. alias })
      local aliases = { ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" }
      metadata["injection.language"] = lang or aliases[alias] or alias
    end, { force = true })
  end,
}
