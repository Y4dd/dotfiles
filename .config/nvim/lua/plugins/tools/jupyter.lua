return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    ft = "markdown.ipynb",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20

      vim.keymap.set("n", "<leader>ip", function()
        local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
        if venv ~= nil then
          -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
          venv = string.match(venv, "/.+/(.+)")
          vim.cmd(("MoltenInit %s"):format(venv))
        else
          vim.cmd "MoltenInit python3"
        end
      end, { desc = "Initialize Molten for python3", silent = true })
    end,
    config = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_max_lines = 50

      -- change the configuration when editing a python file
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.py",
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
            vim.fn.MoltenUpdateOption("virt_text_output", false)
          else
            vim.g.molten_virt_lines_off_by_1 = false
            vim.g.molten_virt_text_output = false
          end
        end,
      })

      -- Undo those config changes when we go back to a markdown or quarto file
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.qmd", "*.md", "*.ipynb" },
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
            vim.fn.MoltenUpdateOption("virt_text_output", true)
          else
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_virt_text_output = true
          end
        end,
      })
    end,
  },
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown.ipynb" },
    dependencies = { "jmbuhr/otter.nvim" },
    opts = {
      lspFeatures = {
        languages = { "python" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    keys = {
      {
        "<leader>rc",
        function()
          require("quarto.runner").run_cell()
        end,
        mode = "n",
        desc = "Run cell",
      },
      {
        "<leader>ra",
        function()
          require("quarto.runner").run_above()
        end,
        mode = "n",
        desc = "Run cell and above",
      },
      {
        "<leader>rA",
        function()
          require("quarto.runner").run_all()
        end,
        mode = "n",
        desc = "Run all cells",
      },
      {
        "<leader>rl",
        function()
          require("quarto.runner").run_line()
        end,
        mode = "n",
        desc = "Run line",
      },
      {
        "<leader>r",
        function()
          require("quarto.runner").run_range()
        end,
        mode = "v",
        desc = "Run visual range",
      },
      {
        "<leader>RA",
        function()
          require("quarto.runner").run_all(true)
        end,
        mode = "n",
        desc = "Run all cells of all languages",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "ipynb",
        callback = function()
          require("quarto").activate()
        end,
      })
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "quarto",
      output_extension = "qmd",
      force_ft = "markdown.ipynb",
    },
  },
}
