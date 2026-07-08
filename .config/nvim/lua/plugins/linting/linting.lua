return {
  "rshkarin/mason-nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mfussenegger/nvim-lint",
    "williamboman/mason.nvim",
  },
  config = function()
    local lint = require "lint"

    -- All filetypes are routed by the registry (lua/languages.lua).
    lint.linters_by_ft = require("utils").linters_by_ft(require "languages")

    local lint_augroup = vim.api.nvim_create_augroup("CustomNvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    require("mason-nvim-lint").setup {
      ensure_installed = require("utils").tools_from_ft(lint.linters_by_ft),
      automatic_installation = false,
    }
  end,
}
