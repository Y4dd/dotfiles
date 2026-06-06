return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = {
    "zapling/mason-conform.nvim",
  },
  opts = function()
    return {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettierd" },
        html = { "prettierd" },
        python = { "ruff" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        go = { "gofumpt", "golines" },
        rust = { "rustfmt" },
        toml = { "taplo" },
        cs = { "csharpier" },
      },

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
