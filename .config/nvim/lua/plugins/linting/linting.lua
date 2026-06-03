return {
  "rshkarin/mason-nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mfussenegger/nvim-lint",
    "williamboman/mason.nvim",
  },
  config = function()
    local lint = require "lint"

    lint.linters_by_ft = {
      python = { "ruff" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("CustomNvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Install every linter referenced above, deduped.
    local ensure_installed = {}
    for _, linters in pairs(lint.linters_by_ft) do
      for _, linter in ipairs(linters) do
        ensure_installed[linter] = true
      end
    end

    require("mason-nvim-lint").setup {
      ensure_installed = vim.tbl_keys(ensure_installed),
      automatic_installation = false,
    }
  end,
}
