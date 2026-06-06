-- Per-language DAP adapters. nvim-dap core + dap-ui + keymaps live in
-- dap/core.lua; this file only registers the language adapters, each
-- lazy-loaded by filetype.
return {
  {
    "NicholasMata/nvim-dap-cs",
    ft = "cs",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      dap_configurations = {
        {
          type = "coreclr",
          name = "Attach remote",
          mode = "remote",
          request = "attach",
        },
      },
    },
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      dap_configurations = {
        {
          type = "go",
          name = "Debug main.go",
          request = "launch",
          program = "${workspaceFolder}",
          cwd = vim.fn.getcwd(),
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup(vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python3")
    end,
    keys = {
      {
        "<leader>dpr",
        function()
          require("dap-python").test_method()
        end,
        desc = "DAP Python test method",
      },
    },
  },
  {
    "jbyuki/one-small-step-for-vimkind",
    ft = "lua",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require "dap"
      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance",
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback { type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 }
      end
    end,
  },
}
