return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
    "OverseerBuild",
    "OverseerClose",
    "OverseerTaskAction",
    "OverseerSaveBundle",
    "OverseerLoadBundle",
    "OverseerDeleteBundle",
  },
  keys = {
    { "<leader>cr", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
    { "<leader>ct", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
  },
  config = function()
    local overseer = require "overseer"
    local template_dir = vim.fn.stdpath "config" .. "/lua/plugins/tools/overseer/templates"

    overseer.setup {
      strategy = {
        "toggleterm",
        direction = "vertical",
        size = 100,
        auto_scroll = true,
      },
    }

    -- Load all templates from the folder
    local function load_templates()
      local handle = vim.uv.fs_scandir(template_dir)
      if not handle then
        return
      end

      while true do
        local name, type = vim.uv.fs_scandir_next(handle)
        if not name then
          break
        end
        if type == "file" and name:match "%.lua$" then
          local mod_name = "plugins.tools.overseer.templates." .. name:gsub("%.lua$", "")
          local ok, templates = pcall(require, mod_name)
          if ok and templates then
            if vim.islist(templates) then
              for _, template in ipairs(templates) do
                overseer.register_template(template)
              end
            else
              overseer.register_template(templates)
            end
          else
            vim.notify("Failed to load Overseer template: " .. mod_name, vim.log.levels.ERROR)
          end
        end
      end
    end

    load_templates()
  end,
}
