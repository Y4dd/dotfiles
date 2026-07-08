return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = {
    "zapling/mason-conform.nvim",
  },
  opts = function()
    local languages = require "languages"
    local utils = require "utils"
    return {
      -- All filetypes are routed by the registry (lua/languages.lua).
      formatters_by_ft = utils.formatters_by_ft(languages),

      formatters = {
        golines = {
          prepend_args = { "--max-len=80" },
        },
        csharpier = {
          command = "csharpier",
          args = { "format", "--write-stdout" },
        },
      },

      format_on_save = function(bufnr)
        -- notebook buffers carry the dotted ft "markdown.ipynb"; conform splits
        -- that and would run the markdown formatter, reflowing jupytext cells.
        if vim.bo[bufnr].filetype:find("ipynb", 1, true) then
          return nil
        end
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end,
    }
  end,
  config = function(_, opts)
    require("conform").setup(opts)
    require("mason-conform").setup {
      ensure_installed = require("utils").tools_from_ft(opts.formatters_by_ft),
    }
  end,
}
