require "nvchad.mappings"
local map = vim.keymap.set
local unmap = vim.keymap.del

-- Basics
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>\\", ":vsplit<CR>", { desc = "Vertical Split", noremap = true })
map("n", "<leader>-", ":split<CR>", { desc = "Horizontal Split", noremap = true })

-- Tabs
map({ "n", "t" }, "<leader>tc", ":$tabnew<CR>", { noremap = true, desc = "Tab: New" })
map({ "n", "t" }, "<leader>tx", ":tabclose<CR>", { noremap = true, desc = "Tab: Close" })
map({ "n", "t" }, "<C-Tab>", ":tabn<CR>", { noremap = true, desc = "Tab: Next" })
map({ "n", "t" }, "<C-S-Tab>", ":tabp<CR>", { noremap = true, desc = "Tab: Previous" })

-- Move to buffer using Alt+bufnr
for i = 1, 9 do
  map("n", string.format("<A-%s>", i), function()
    local buf = vim.t.bufs[i]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_set_current_buf(buf)
    else
      vim.notify(string.format("No buffer assigned to Alt-%d", i), vim.log.levels.WARN)
    end
  end, { silent = true, noremap = true, desc = string.format("Buffer: Go to %d", i) })
end

for i = 1, 9 do
  map("n", string.format("<C-%s>", i), function()
    local tabs = vim.api.nvim_list_tabpages()
    local tab = tabs[i]

    if tab then
      vim.api.nvim_set_current_tabpage(tab)
    else
      vim.notify(string.format("No tab assigned to Ctrl-%d", i), vim.log.levels.WARN)
    end
  end, { silent = true, noremap = true, desc = string.format("Tab: Go to %d", i) })
end

-- Terminal
unmap("n", "<leader>h") -- Originally used for NvChad term splits
unmap("n", "<leader>v")

map("n", "<leader>t\\", function()
  require("nvchad.term").new {
    pos = "vsp",
  }
end, {
  desc = "Term: Vertical Split",
  noremap = true,
})

map("n", "t-", function()
  require("nvchad.term").new {
    pos = "sp",
  }
end, {
  desc = "Term: Horizontal Split",
  noremap = true,
})

map({ "n", "t" }, "<leader>gg", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "lazygit",
    cmd = "lazygit",
  }
end, { noremap = true, silent = true, desc = "Open LazyGit Terminal" })
