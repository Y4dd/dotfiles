# CLAUDE.md

Guidance for working in this Neovim configuration.

## What this is

A personal Neovim config built **on top of NvChad v2.5**. NvChad is consumed as a
*plugin* (`NvChad/NvChad`, branch `v2.5`), not a framework you edit — you import its
modules (`require "nvchad.options"`, `require "nvchad.mappings"`, etc.) and override or
extend them. Plugin management is **lazy.nvim**. Theme/highlight system is **base46**
(NvChad's), which compiles highlight groups to a cache loaded via `dofile`.

Do not edit NvChad internals; they live outside this repo (in lazy's plugin dir). Change
behavior by overriding in the files here.

## Load order (`init.lua`)

1. Set `base46_cache`, leaders, `lua_snippets_path`.
2. Bootstrap + `require("lazy").setup` with two imports: the `NvChad/NvChad` spec
   (`import = "nvchad.plugins"`) and our `{ import = "plugins" }` → `lua/plugins/init.lua`.
3. `dofile` the base46 `defaults` + `statusline` caches (applies the theme).
4. `require "options"` → `require "nvchad.autocmds"` → `require "autocmds"`.
5. `mappings` is loaded inside `vim.schedule(...)` (deferred to after startup).

## Directory layout

```
init.lua                 entry point (load order above)
lua/
  chadrc.lua             NvChad config table (theme, term sizes, nvdash, lsp.signature)
  options.lua            vim options on top of nvchad.options (folds, indent, scrolloff…)
  mappings.lua           GLOBAL keymaps (see Keymap ownership below)
  autocmds.lua           autocmds only (terminal buffer maps, BufDelete→Nvdash, NewNotebook cmd)
  utils.lua              shared helpers (currently: tools_from_ft)
  configs/
    lazy.lua             lazy.nvim setup table (UI, disabled rtp plugins)
    palette.lua          color table consumed by the snippets file
  snippets/              luasnip lua-snippet files (loaded via lua_snippets_path)
  plugins/
    init.lua             THE plugin manifest — every spec is wired here
    ai/  dap/  editing/  linting/  lsp/  tools/  ui/   one spec (or list) per file
after/ftdetect/          custom filetype detection (strudel, terraform)
```

## Plugin wiring convention

`lua/plugins/init.lua` is the single manifest. Every plugin file is pulled in there,
either as `require "plugins.<group>.<name>"` (a file returning a spec or a list of specs)
or as an inline `{ ... }` spec. **A plugin file does nothing until it is referenced in
`plugins/init.lua`** — orphaned files in the tree are dead code. A few files are wired but
intentionally toggled off via a commented `require` line (e.g. `render-markdown`,
`strudel`); leave those unless asked. Prefer `enabled = false` in the spec over commenting
the require if disabling something new.

A plugin file may `return` a single spec table **or** a list of specs (see
`editing/treesitter.lua`, `tools/jupyter.lua`).

## Keymap ownership (single source of truth — keep it this way)

- **Global, always-on maps** → `lua/mappings.lua`. Always include a `desc` (it surfaces in
  `:NvCheatsheet` / which-key).
- **Plugin-specific maps that should lazy-load the plugin** → `keys = {}` in that plugin's
  own spec (dap, overseer, jupyter, quarto, etc.).
- **Buffer-local-on-event maps** → co-located with the feature:
  - LSP maps live in `plugins/lsp/lspconfig.lua` (an `LspAttach` autocmd in its `config`).
  - Terminal-mode maps live in the `TermOpen` autocmd in `autocmds.lua`.

Before adding a map, grep for the lhs to avoid collisions (a past `<leader>ra` clash
between LSP rename and Quarto run-above is why this rule exists; rename is now
`<leader>rn`, and the `<leader>r*` prefix belongs to the Quarto runner).

## Helpers

`utils.tools_from_ft(by_ft)` — flattens a `*_by_ft` map (`{ python = {"ruff"}, ... }`) into
a deduped list of tool names for mason `ensure_installed`. Used by `editing/conform.lua`
and `linting/linting.lua`. Reuse it instead of re-writing the flatten loop.

## Tooling pipelines

- **Formatting**: `editing/conform.lua` owns conform.nvim; `formatters_by_ft` drives both
  formatting and (via `tools_from_ft`) mason-conform auto-install. format-on-save is on.
- **Linting**: `linting/linting.lua` owns nvim-lint + mason-nvim-lint; same pattern.
  (There is exactly ONE lint config — earlier duplicate files under `configs/` were dead
  and removed.)
- **LSP**: `lsp/lspconfig.lua` lists servers in `servers` and calls `vim.lsp.enable`.
  Per-server overrides via `vim.lsp.config(name, {...})`. Mason provides the binaries.
- **Treesitter**: uses the **`main`** branch (not legacy `master`). Highlight + install are
  driven by NvChad's core; this file only extends the parser list and owns textobjects.
  Requires the `tree-sitter` CLI on PATH. Folds are native (`vim.treesitter.foldexpr` in
  `options.lua`).

## Gotchas

- `nvim-tree.lua` is **opts-only** and merges by name with NvChad's base spec, which
  already supplies `cmd = { NvimTreeToggle, NvimTreeFocus }` — so it is NOT eager-loaded.
  Don't "fix" it by adding triggers.
- Theme is set in `chadrc.lua` (`M.base46.theme`). Highlights come from the base46 cache;
  if colors look stale after a change, rebuild via `:Lazy build base46` / restart.
- Python host is pinned: `vim.g.python3_host_prog` → `~/.virtualenvs/neovim/bin/python3`.
  That venv must have `pynvim` + `jupyter_client` (molten's runtime deps), or molten can't
  execute anything.
- **molten + python3 provider**: NvChad disables the python3 provider for startup speed
  (`nvchad.options` sets `g.loaded_python3_provider = 0`). `options.lua` re-enables it
  (`vim.g.loaded_python3_provider = nil`) because molten-nvim is a Python remote plugin.
  Don't remove that line — without it `has('python3')` is 0 and molten is dead.
- **molten rplugin manifest goes stale.** molten is lazy-loaded (`ft = "markdown.ipynb"`),
  so `:UpdateRemotePlugins` from a normal buffer registers nothing (its `rplugin/` dir
  isn't on the runtimepath yet) and writes an empty manifest — symptom is
  `E117: Unknown function: MoltenStatusLineInit` / `provider#python3#Require` on opening a
  notebook. Fix: **open any `.ipynb` first** (loads molten), then `:UpdateRemotePlugins`,
  then restart. Re-do this after any molten update.

## Conventions

- **Formatting**: stylua, config in `.stylua.toml` (2-space indent, 120 cols, double
  quotes, no call parens). Run `stylua lua/` after Lua edits.
- **Version control**: the user tracks this via a `git dotfiles` bare repo, not a `.git`
  here. Don't `git init`. Deletions are recoverable; prefer deleting dead code over
  leaving commented-out "graveyards."

## Verifying changes

```sh
# config loads with no errors
nvim --headless "+lua print('OK')" +qa

# syntax-check edited Lua files
luac -p lua/path/to/file.lua          # or: luajit -bl <file> >/dev/null

# plugin health / duplicate specs
nvim --headless "+checkhealth lazy" +qa     # or open :Lazy
```

Manual smoke test for tooling changes: save a `.py` and a `.lua` file (lint + format
fire — check `:ConformInfo`), and `:NvCheatsheet` for keymap descriptions.
