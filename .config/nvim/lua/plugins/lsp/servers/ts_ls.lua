local handlers = require "plugins.lsp.handlers"

vim.lsp.config("ts_ls", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    handlers.on_attach(client, bufnr)
  end,
  on_init = handlers.on_init,
  capabilities = handlers.capabilities(),
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, cb)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local git_dir = vim.fs.find(".git", {
      upward = true,
      path = fname,
      type = "directory",
    })[1]
    local project_root = git_dir and vim.fs.dirname(git_dir)
    if not project_root then
      local pkg = vim.fs.find("package.json", {
        upward = true,
        path = fname,
      })[1]
      project_root = pkg and vim.fs.dirname(pkg)
    end

    cb(project_root)
  end,
  reuse_client = function(client, config)
    return client.name == "ts_ls" and client.config.root_dir == config.root_dir
  end,
  single_file_support = false,
  settings = {
    -- Add any tsserver-specific settings if needed
  },
})
