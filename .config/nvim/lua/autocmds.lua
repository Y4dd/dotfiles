vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_cmds", { clear = true }),
  desc = "My custom global LSP handlers",
  callback = function(event)
    -- local client = vim.lsp.get_client_by_id(event.data.client_id)
    local function opts(desc)
      return { buffer = event.buf, desc = "LSP " .. desc }
    end

    local map = vim.keymap.set
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts "List workspace folders")

    map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
    map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")

    map("n", "gh", vim.lsp.buf.hover, opts "Show hover hint")
    map("n", "gH", vim.diagnostic.open_float, opts "Show hover diagnostic")
    map("n", "gs", vim.lsp.buf.signature_help, opts "Show signature")
    map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
    map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
    map("n", "gr", vim.lsp.buf.references, opts "References")
    map("n", "gi", vim.lsp.buf.implementation, opts "Implementation")
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts "Code Action")
  end,
})

-- -- Autoclose LazyGit
vim.api.nvim_create_autocmd({ "TermClose" }, {
  callback = function(args)
    if type(vim.g.nvchad_terms) ~= "table" then
      return
    end

    local term = vim.g.nvchad_terms[tostring(args.buf)]
    if term and term["id"] == "lazygit" and vim.api.nvim_buf_is_valid(args.buf) then
      vim.cmd("bw " .. args.buf)
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

    vim.keymap.set("t", "<leader>ta", [[<C-\><C-n>:tabnew<CR>]], opts)
    vim.keymap.set("t", "<leader>tc", [[<C-\><C-n>:tabclose<CR>]], opts)

    if vim.bo.buftype == "terminal" then
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(buf, "Terminal " .. buf)
    end
  end,
})
