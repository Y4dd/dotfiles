return {
  "lervag/vimtex",
  ft = "tex",
  init = function()
    vim.g.vimtex_view_method = "zathura"
    -- vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
    vim.g.vimtex_imaps_enabled = 0
    vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull",
      "Overfull",
      "LaTeX Warning: .\\+ float specifier changed to",
      "Package hyperref Warning: Token not allowed in a PDF string",
    }
  end,
}
