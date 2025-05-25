local util = require "lspconfig.util"
local handlers = require "plugins.lsp.handlers"

vim.lsp.config("gopls", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    handlers.on_attach(client, bufnr)
  end,
  on_init = handlers.on_init,
  capabilities = handlers.capabilities(),
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gotmpl", "gowork" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unusedvariable = true,
      },
      usePlaceholders = true,
      staticcheck = true,
    },
  },
})
