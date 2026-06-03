return {
  { "kaarmu/typst.vim", ft = "typst" },
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      open_cmd = "brave --app=%s --password-store=basic > /dev/null 2>&1",
      follow_cursor = true,
    },
    config = function(_, opts)
      require("typst-preview").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          local wk = require "which-key"
          vim.keymap.set("n", "<localleader>ll", "<cmd>TypstPreviewToggle<CR>", { buffer = true })
          vim.keymap.set("n", "<localleader>lp", "<cmd>TypstPreviewFollowCursor<CR>", { buffer = true })
          vim.keymap.set("n", "<localleader>lc", "<cmd>make<CR>", { buffer = true })
          wk.add({
            { "<localleader>l", group = "Typst/Latex" },
            { "<localleader>ll", desc = "Toggle Preview" },
            { "<localleader>lp", desc = "Follow Cursor" },
            { "<localleader>lc", desc = "Compile (Make)" },
          }, { buffer = true })
        end,
      })
    end,
  },
}
