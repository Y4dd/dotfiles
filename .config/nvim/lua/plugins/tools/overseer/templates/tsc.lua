return {
  name = "Typescript Compile",
  builder = function()
    return {
      cmd = { "tsc" },
      args = { "-b" },
      components = {
        { "on_output_parse", problem_matcher = "$tsc" },
        { "on_output_quickfix", open_on_match = true },
        "unique",
      },
    }
  end,
  condition = {
    filetype = { "typescript", "typescriptreact" },
    root = { "tsconfig.json" },
  },
}
