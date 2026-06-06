return {
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
}
