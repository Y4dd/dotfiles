return {
  "mfussenegger/nvim-dap-python",
  ft = "python",
  dependencies = { "mfussenegger/nvim-dap" },
  opts = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python3",
  keys = {
    {
      "<leader>dpr",
      function()
        require("dap-python").test_method()
      end,
      desc = "DAP Python test method",
    },
  },
}
