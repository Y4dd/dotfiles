local api = require "nvim-tree.api"

local function edit_or_open()
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file
    api.node.open.edit()
    -- Close the tree if file was opened
    api.tree.close()
  end
end

-- open as vsplit on current node
local function vsplit_preview()
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file as vsplit
    api.node.open.vertical()
  end

  -- Finally refocus on tree if it was lost
  api.tree.focus()
end

local function mapped_on_attach(bufnr)
  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  -- Load Default Mappings
  api.config.mappings.default_on_attach(bufnr)

  -- Load custom mappings
  vim.keymap.set("n", "l", edit_or_open, opts "Edit Or Open")
  vim.keymap.set("n", "L", vsplit_preview, opts "Vsplit Preview")
  vim.keymap.set("n", "h", api.tree.close, opts "Close")
  vim.keymap.set("n", "H", api.tree.collapse_all, opts "Collapse All")
end

return {
  "nvim-tree/nvim-tree.lua",
  opts = {
    on_attach = mapped_on_attach,
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    filters = {
      dotfiles = false,
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    view = {
      width = {
        min = 45,
        max = -1,
        padding = 1,
      },
    },
  },
}
