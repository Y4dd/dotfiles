return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest",
  config = function()
    require("mcphub").setup {
      auto_approve = false,
      extensions = {
        avante = {
          make_slash_commands = true,
        },
      },
    }
  end,
}
