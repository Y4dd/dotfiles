local uv = vim.uv or vim.loop

-- virtualfish keeps environments under WORKON_HOME (default ~/.virtualenvs)
local function virtualfish_home()
  return os.getenv "VIRTUALFISH_HOME" or os.getenv "WORKON_HOME" or (vim.env.HOME .. "/.virtualenvs")
end

local function list_venvs(home)
  local names = {}
  local ok, iter = pcall(vim.fs.dir, home)
  if not ok then
    return names
  end
  for name, typ in iter do
    if typ == "directory" and uv.fs_stat(home .. "/" .. name .. "/bin/python") then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

local function jupyter_kernels_dir()
  return (os.getenv "XDG_DATA_HOME" or (vim.env.HOME .. "/.local/share")) .. "/jupyter/kernels"
end

-- Register an ipykernel for `venv` (installing ipykernel into it first if needed),
-- then MoltenInit the resulting kernel. Kernelspec names are always lowercased.
local function ensure_kernel_and_init(home, venv)
  local kname = venv:lower()
  local py = home .. "/" .. venv .. "/bin/python"

  if uv.fs_stat(jupyter_kernels_dir() .. "/" .. kname .. "/kernel.json") then
    vim.cmd("MoltenInit " .. kname)
    return
  end

  local function register()
    vim.notify("Registering Jupyter kernel '" .. kname .. "'...", vim.log.levels.INFO)
    vim.system(
      { py, "-m", "ipykernel", "install", "--user", "--name", kname, "--display-name", "Python (" .. venv .. ")" },
      { text = true },
      function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.cmd("MoltenInit " .. kname)
          else
            vim.notify("ipykernel install failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
          end
        end)
      end
    )
  end

  -- ensure ipykernel is present in the venv before registering it
  vim.system({ py, "-c", "import ipykernel" }, { text = true }, function(res)
    if res.code == 0 then
      vim.schedule(register)
    else
      vim.schedule(function()
        vim.notify("Installing ipykernel into '" .. venv .. "'...", vim.log.levels.INFO)
      end)
      vim.system({ py, "-m", "pip", "install", "ipykernel" }, { text = true }, function(pres)
        vim.schedule(function()
          if pres.code == 0 then
            register()
          else
            vim.notify("pip install ipykernel failed:\n" .. (pres.stderr or ""), vim.log.levels.ERROR)
          end
        end)
      end)
    end
  end)
end

local function molten_pick_and_init()
  -- fast path: honor an already-active env (e.g. you ran `vf activate` first)
  local active = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
  if active then
    ensure_kernel_and_init(vim.fs.dirname(active), vim.fs.basename(active))
    return
  end

  local home = virtualfish_home()
  local venvs = list_venvs(home)
  if #venvs == 0 then
    vim.notify("No virtualenvs found in " .. home, vim.log.levels.WARN)
    return
  end
  vim.ui.select(venvs, { prompt = "Jupyter venv:" }, function(choice)
    if choice then
      ensure_kernel_and_init(home, choice)
    end
  end)
end

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

      vim.keymap.set("n", "<leader>ip", molten_pick_and_init, { desc = "Pick venv & init Molten", silent = true })

      -- Buffer-local Molten maps for notebook/quarto buffers. Registered at
      -- startup so the first-opened notebook gets them too (the FileType event
      -- for that buffer fires after this autocmd is already armed).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown.ipynb", "quarto" },
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
          end
          -- evaluation (complements the quarto runner on <leader>r*)
          map("n", "<leader>ie", ":MoltenEvaluateOperator<CR>", "Evaluate operator")
          map("v", "<leader>ie", ":<C-u>MoltenEvaluateVisual<CR>gv", "Evaluate selection")
          map("n", "<leader>il", "<cmd>MoltenEvaluateLine<cr>", "Evaluate line")
          map("n", "<leader>ir", "<cmd>MoltenReevaluateCell<cr>", "Re-evaluate cell")
          -- output management
          map("n", "<leader>io", "<cmd>noautocmd MoltenEnterOutput<cr>", "Enter output window")
          map("n", "<leader>ih", "<cmd>MoltenHideOutput<cr>", "Hide output")
          map("n", "<leader>id", "<cmd>MoltenDelete<cr>", "Delete cell output")
          -- kernel control
          map("n", "<leader>ix", "<cmd>MoltenInterrupt<cr>", "Interrupt kernel")
          map("n", "<leader>iR", "<cmd>MoltenRestart<cr>", "Restart kernel")
        end,
      })
    end,
    config = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = false
      -- enter the floating output on a single <leader>io press (default
      -- "open_then_enter" needs two: one to open, one to enter)
      vim.g.molten_enter_output_behavior = "open_and_enter"
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
      -- Activate the quarto/otter code runner per buffer. Must be a FileType
      -- autocmd: a BufEnter pattern of "ipynb" only matches a file literally
      -- named "ipynb", so notebooks never activated and <leader>r* errored with
      -- "code runner isn't initialized".
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "markdown.ipynb" },
        callback = function()
          require("quarto").activate()
        end,
      })
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    event = "BufReadCmd *.ipynb",
    opts = {
      style = "quarto",
      output_extension = "qmd",
      force_ft = "markdown.ipynb",
    },
  },
}
