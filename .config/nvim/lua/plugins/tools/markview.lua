return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  opts = {
    preview = {
      -- jupytext gives notebook buffers the compound ft "markdown.ipynb", which
      -- isn't in markview's default list, so cells never rendered. Keep the
      -- defaults and add it (this key replaces, it doesn't merge).
      filetypes = { "markdown", "markdown.ipynb", "quarto", "rmd", "typst", "asciidoc" },
    },
    typst = {
      enable = false,
    },
  },
}
