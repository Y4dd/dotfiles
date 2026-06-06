return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = false, -- intentionally off; flip to true to use
  opts = {
    completions = {
      lsp = { enabled = true },
    },
    file_types = { "markdown", "Avante" },
  },
  ft = { "markdown", "Avante" },
}
