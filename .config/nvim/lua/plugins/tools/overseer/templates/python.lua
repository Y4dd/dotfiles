return {
  name = "python run file",
  builder = function()
    -- Prefer an active venv, fall back to python3 on PATH.
    local venv = vim.env.VIRTUAL_ENV
    local python = venv and (venv .. "/bin/python") or "python3"
    return {
      cmd = { python },
      args = { vim.fn.expand "%:p" },
      cwd = vim.fn.expand "%:p:h",
      components = {
        "default",
        "unique",
        {
          -- Parse Python tracebacks (File "x.py", line N) into the quickfix.
          "on_output_quickfix",
          errorformat = [[%A  File "%f"\, line %l\,%m,%C    %.%#,%Z%[%^ ]%\@=%m]],
        },
      },
    }
  end,
  condition = {
    filetype = { "python" },
  },
}
