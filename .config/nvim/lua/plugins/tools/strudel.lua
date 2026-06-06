return {
  "gruvw/strudel.nvim",
  enabled = false, -- intentionally off; flip to true to use
  ft = { "strudel" },
  build = "npm install",
  config = function()
    require("strudel").setup {
      update_on_save = true,
    }
  end,
}
