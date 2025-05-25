local handlers = require "plugins.lsp.handlers"

vim.lsp.config("omnisharp", {
  cmd = {
    vim.fn.stdpath "data" .. "/mason/bin/OmniSharp",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
  },
  enable_editorconfig_support = true,
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
  handlers = {
    ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
    ["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
    ["textDocument/references"] = require("omnisharp_extended").references_handler,
    ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
  },
  capabilities = handlers.capabilities(),
  on_attach = handlers.on_attach,
  on_init = handlers.on_init,
})
