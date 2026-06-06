-- Disabled, kept (not deleted). A toggleterm-based LazyGit terminal — redundant
-- with the nvchad.term LazyGit on <leader>gg (mappings.lua), so it's off by
-- default. Flip `enabled` to true to use this version instead.
--
-- This is config-only (no plugin repo), so it returns an empty spec list and
-- stays inert under auto-import while disabled.
local enabled = false

if enabled then
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit_terminal = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    display_name = "LazyGit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
      border = "double",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.9)
      end,
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  _G.ToggleLazyGit = function()
    lazygit_terminal:toggle()
  end

  vim.api.nvim_create_user_command("LazyGitToggle", "lua _G.ToggleLazyGit()", {
    desc = "Toggle LazyGit terminal window",
  })
end

return {}
