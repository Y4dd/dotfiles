return {
  "gruvw/strudel.nvim",
  ft = { "strudel" },
  build = "npm install",
  config = function()
    require("strudel").setup {
      update_on_save = true,
    }
  end,
}
