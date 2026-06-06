vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    local opts = { buffer = true }
    vim.keymap.set("t", "<C-x>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n>:bd!<CR>]], opts)

    if vim.bo.buftype == "terminal" then
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(buf, "Terminal " .. buf)
    end
  end,
})

local default_notebook = [[
  {
     "cells":[
        {
           "cell_type":"markdown",
           "metadata":{},
           "source":[""]
        }
     ],
     "metadata":{
        "author":"Amjad Shomali",
        "kernelspec":{
           "display_name":"Python 3",
           "language":"python",
           "name":"python3"
        },
        "language_info":{
           "codemirror_mode":{
              "name":"ipython"
           },
           "file_extension":".py",
           "mimetype":"text/x-python",
           "name":"python",
           "nbconvert_exporter":"python",
           "pygments_lexer":"ipython3",
           "execute":{
              "enabled":true,
              "cache":true
           },
           "format":{
              "html":{
                 "theme":"cosmo",
                 "monobackgroundcolor":"#f6f6f6"
              }
           }
        }
     },
     "nbformat":4,
     "nbformat_minor":5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print "Error: Could not open new notebook file for writing."
  end
end

vim.api.nvim_create_user_command("NewNotebook", function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = "file",
})
