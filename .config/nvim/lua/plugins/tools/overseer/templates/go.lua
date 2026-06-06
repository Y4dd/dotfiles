return {
  name = "go run",
  builder = function()
    return {
      cmd = { "go", "run" },
      args = { "." },
      cwd = ".", -- Consider making this dynamic, e.g., vim.fn.expand('%:p:h') for current file's dir
      components = { "run" },
    }
  end,
  condition = {
    filetype = { "go" },
    root = { "go.mod" },
  },
}
