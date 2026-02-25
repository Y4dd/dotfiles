return {
  "neovim/nvim-lspconfig",
  config = function()
    require("nvchad.configs.lspconfig").defaults()
    local servers = {
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
      "basedpyright",
      "gopls",
      "lua_ls",
      "dartls",
      "tailwindcss",
      "ltex_plus",
      "typst_lsp",
      "nil_ls",
      -- Custom
      "ts_ls",
      "emmet_language_server",
      "omnisharp",
    }

    -- Custom config
    vim.lsp.config("ts_ls", {
      root_markers = { ".git" },
    })

    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "basic",
          },
        },
      },
    })

    vim.lsp.config("omnisharp", {
      handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
        ["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
        ["textDocument/references"] = require("omnisharp_extended").references_handler,
        ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
      },
    })

    vim.lsp.enable(servers)
  end,
}
