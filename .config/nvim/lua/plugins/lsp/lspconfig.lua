return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    dofile(vim.g.base46_cache .. "lsp")
    require("nvchad.lsp").diagnostic_config()

    -- Global fallback to .git projects
    vim.lsp.config("*", {
      root_dir = function(bufnr, cb)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local git_dir = vim.fs.find(".git", {
          upward = true,
          path = fname,
          type = "directory",
        })[1]
        cb(git_dir and vim.fs.dirname(git_dir) or nil)
      end,

      reuse_client = function(client, config)
        return client.name == config.name and client.config.root_dir == config.root_dir
      end,
    })
  end,
}
