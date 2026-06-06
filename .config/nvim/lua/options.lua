require "nvchad.options"

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.relativenumber = true

vim.opt.laststatus = 3

-- vim.opt sets both the global default and the current window's local value,
-- so new splits inherit treesitter folding (vim.wo only touches one window).
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldnestmax = 4

vim.o.scrolloff = 8

-- NvChad disables the python3 provider for faster startup; molten-nvim needs it.
-- Deleting the flag re-enables on-demand provider detection against the host below.
vim.g.loaded_python3_provider = nil
vim.g.python3_host_prog = vim.fn.expand "~/.virtualenvs/neovim/bin/python3"
