return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- as per your original config
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "ravitemer/mcphub.nvim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
  },
  opts = {
    provider = "gemini_preview",
    cursor_applying_provider = "groq",
    behaviour = {
      enable_cursor_planning_mode = true,
    },
    vendors = {
      gemini_preview = {
        __inherited_from = "gemini",
        model = "gemini-2.5-flash-preview-04-17",
      },
      groq = { -- define groq provider
        __inherited_from = "openai",
        api_key_name = "GROQ_API_KEY",
        endpoint = "https://api.groq.com/openai/v1/",
        model = "llama-3.3-70b-versatile",
        max_completion_tokens = 32768,
      },
    },
    gemini = {
      endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
      model = "gemini-2.5-flash-preview-04-17",
    },
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub:get_active_servers_prompt()
    end,
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
    disabled_tools = {
      "list_files",
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",
    },
  },
  -- Example keys section you might want to add:
  -- keys = {
  --   { "<leader>aa", function() require("avante.cmd").Avante() end, desc = "Avante Ask" },
  --   { "<leader>ac", function() require("avante.cmd").AvanteChat() end, desc = "Avante Chat" },
  -- }
}
