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
      },

      formatters = {
        golines = {
          prepend_args = { "--max-len=80" },
        },
        -- black = {
        --   prepend_args = { "--fast", "--line-length", "80" },
        -- },
      },

      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    }
  end,
  config = function(_, opts)
    require("conform").setup(opts)
    -- Auto-install formatters
    local formatters = {}
    for _, ft_formatters in pairs(opts.formatters_by_ft) do
      for _, formatter in ipairs(ft_formatters) do
        formatters[formatter] = true
      end
    end

    require("mason-conform").setup {
      ensure_installed = vim.tbl_keys(formatters),
    }
  end,
}
