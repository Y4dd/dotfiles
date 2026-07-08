-- Buffer-local LSP keymaps, co-located with the server config. Set on LspAttach
-- so they only exist in buffers that actually have a language server.
local function on_attach(event)
  local function opts(desc)
    return { buffer = event.buf, desc = "LSP " .. desc }
  end

  local map = vim.keymap.set
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")

  map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  map("n", "<leader>rn", require "nvchad.lsp.renamer", opts "NvRenamer")

  map("n", "gh", vim.lsp.buf.hover, opts "Show hover hint")
  map("n", "gH", vim.diagnostic.open_float, opts "Show hover diagnostic")
  map("n", "gs", vim.lsp.buf.signature_help, opts "Show signature")
  map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "gr", vim.lsp.buf.references, opts "References")
  map("n", "gi", vim.lsp.buf.implementation, opts "Implementation")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code Action")
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    require("nvchad.configs.lspconfig").defaults()

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_cmds", { clear = true }),
      desc = "My custom global LSP handlers",
      callback = on_attach,
    })

    -- Pure LSP-only servers (no formatter/linter/dap). Servers tied to a
    -- tooling-bearing language come from the registry (lua/languages.lua).
    local extra_servers = {
      "graphql",
      "terraformls",
      "gitlab_ci_ls",
      "helm_ls",
      "nginx_language_server",
      "kotlin_language_server",
      "hls",
      "dartls",
      "tailwindcss",
      "ltex_plus",
      "tinymist",
      "nil_ls",
      "emmet_language_server",
    }
    local servers = vim.list_extend(extra_servers, require("utils").lsp_servers(require "languages"))

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
