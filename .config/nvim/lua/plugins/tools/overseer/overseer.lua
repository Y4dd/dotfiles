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
    { "<leader>cx", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
    {
      "<leader>cl",
      function()
        local overseer = require "overseer"
        local tasks = overseer.list_tasks {}
        if vim.tbl_isempty(tasks) then
          return vim.notify("Overseer: no task to restart", vim.log.levels.WARN)
        end
        local last = tasks[1]
        for _, t in ipairs(tasks) do
          if t.id > last.id then
            last = t
          end
        end
        last:restart(true)
      end,
      desc = "Overseer Restart Last Task",
    },
    { "<leader>cS", "<cmd>OverseerSaveBundle<cr>", desc = "Overseer Save Bundle" },
    { "<leader>cL", "<cmd>OverseerLoadBundle<cr>", desc = "Overseer Load Bundle" },
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
      -- Patch nvim-dap so launch.json preLaunchTask/postDebugTask run as tasks.
      dap = true,
      task_list = {
        direction = "bottom",
        min_height = 10,
        max_height = 18,
        default_detail = 1,
      },
      component_aliases = {
        -- Shared stack for our run/build templates: builtin `default` (status
        -- + notify + auto-dispose), dedupe re-runs, and stream output to the
        -- quickfix list. Builtin aliases are preserved (setup deep-merges).
        run = {
          "default",
          "unique",
          { "on_output_quickfix", open = false },
        },
      },
    }

    overseer.add_template_hook({
      module = "^cargo$",
    }, function(task_defn, util)
      util.add_component(task_defn, { "on_output_quickfix", open = true })
      util.remove_component(task_defn, "on_complete_dispose")
    end)

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
