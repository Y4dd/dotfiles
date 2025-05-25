return {
  "mason-org/mason-lspconfig.nvim",
  event = "VeryLazy",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    local mason = require "mason"
    local mason_lspconfig = require "mason-lspconfig"
    local handlers = require "plugins.lsp.handlers"

    mason.setup()

    local ensure_installed_servers = {
      "html",
      "jsonls",
      "cssls",
      "ts_ls",
      "graphql",
      "terraformls",
      "bashls",
      "gitlab_ci_ls",
      "helm_ls",
      "nginx_language_server",
      "taplo",
      "kotlin_language_server",
      "hls",
      "gopls",
      "lua_ls",
      "basedpyright",
      "omnisharp",
    }

    mason_lspconfig.setup {
      ensure_installed = ensure_installed_servers,
    }

    local common_lsp_opts = {
      on_attach = handlers.on_attach,
      on_init = handlers.on_init,
      capabilities = handlers.capabilities(),
    }

    local custom_server_configs = {
      ["gopls"] = "plugins.lsp.servers.gopls",
      ["lua_ls"] = "plugins.lsp.servers.lua_ls",
      ["basedpyright"] = "plugins.lsp.servers.basedpyright",
      ["ts_ls"] = "plugins.lsp.servers.ts_ls",
      ["omnisharp"] = "plugins.lsp.servers.omnisharp",
    }

    for _, server_name in ipairs(ensure_installed_servers) do
      local custom_config_path = custom_server_configs[server_name]

      if custom_config_path then
        require(custom_config_path)
      else
        vim.lsp.config(server_name, common_lsp_opts)
      end
    end
  end,
}
