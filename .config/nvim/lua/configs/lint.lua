local lint = require "lint"
lint.linters_by_ft = {
  -- lua = { "luacheck" },
  python = { "ruff" },
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
