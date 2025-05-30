return {
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
}
