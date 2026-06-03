return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "scottmckendry/telescope-resession.nvim",
    "nvim-telescope/telescope-media-files.nvim",
  },
  opts = function(_, conf)
    conf.extensions = {
      resession = {
        prompt_title = "Find Sessions",
      },
      projects = {},
      media_files = {},
    }
    pcall(require("telescope").load_extension, "resession")
    pcall(require("telescope").load_extension, "media_files")
  end,
  keys = {
    { "<A-tab>", "<cmd>Telescope buffers sort_lastused=true<CR>", desc = "Telescope: Find buffers" },
    { "<leader>fs", "<cmd>Telescope resession<CR>", desc = "Telescope: Find sessions" },
    { "<leader>fp", "<cmd>Telescope projects<CR>", desc = "Telescope: Recent projects" },
  },
}
