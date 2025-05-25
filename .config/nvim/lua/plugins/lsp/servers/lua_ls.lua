local handlers = require "plugins.lsp.handlers"

vim.lsp.config("lua_ls", {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities(),
  on_init = function(client)
    handlers.on_init(client)

    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      local is_config_dir = path == vim.fn.stdpath "config"
      local has_luarc = vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")

      if not is_config_dir and has_luarc then
        return
      end

      local library_paths = {
        vim.env.VIMRUNTIME,
      }

      if is_config_dir then
        -- Add lazy.nvim plugin paths when editing the config directory
        local lazy_root = vim.fn.stdpath "data" .. "/lazy"
        for _, plugin in ipairs(vim.fn.readdir(lazy_root)) do
          local plugin_path = lazy_root .. "/" .. plugin
          if vim.fn.isdirectory(plugin_path) == 1 then
            table.insert(library_paths, plugin_path)
          end
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          version = "LuaJIT",
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        workspace = {
          checkThirdParty = false,
          library = library_paths,
        },
      })
    end
  end,
  settings = {
    Lua = {},
  },
})
