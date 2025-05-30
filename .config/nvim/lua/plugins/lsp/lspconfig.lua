return {
  "neovim/nvim-lspconfig",
  config = function()
    require("nvchad.configs.lspconfig").defaults()
    local servers = {
      "ts_ls",
      "rust_analyzer",
      "html",
      "jsonls",
      "cssls",
      "graphql",
      "terraformls",
      "bashls",
      "gitlab_ci_ls",
      "helm_ls",
      "nginx_language_server",
      "taplo",
      "kotlin_language_server",
      "hls",
      "lua_ls",
      "omnisharp",
      "basedpyright",
      "gopls",
      -- lua_ls = {},
      -- omnisharp = require "plugins.lsp.servers.omnisharp",
      -- basedpyright = require "plugins.lsp.servers.basedpyright",
      -- gopls = require "plugins.lsp.servers.gopls",
    }
    vim.lsp.enable(servers)
  end,
  -- opts = {
  --   servers = {
  --     ts_ls = {},
  --     rust_analyzer = {},
  --     html = {},
  --     jsonls = {},
  --     cssls = {},
  --     graphql = {},
  --     terraformls = {},
  --     bashls = {},
  --     gitlab_ci_ls = {},
  --     helm_ls = {},
  --     nginx_language_server = {},
  --     taplo = {},
  --     kotlin_language_server = {},
  --     hls = {},
  --     -- lua_ls = {},
  --     omnisharp = require "plugins.lsp.servers.omnisharp",
  --     basedpyright = require "plugins.lsp.servers.basedpyright",
  --     gopls = require "plugins.lsp.servers.gopls",
  --   },
  -- },
  -- config = function()
  --   dofile(vim.g.base46_cache .. "lsp")
  --   require("nvchad.lsp").diagnostic_config()
  --   vim.lsp.config("*", {
  --     root_dir = function(bufnr, cb)
  --       local fname = vim.api.nvim_buf_get_name(bufnr)
  --       local git_dir = vim.fs.find(".git", {
  --         upward = true,
  --         path = fname,
  --         type = "directory",
  --       })[1]
  --       cb(git_dir and vim.fs.dirname(git_dir) or nil)
  --     end,
  --
  --     reuse_client = function(client, config)
  --       return client.name == config.name and client.config.root_dir == config.root_dir
  --     end,
  --   })
  -- end,
}
