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
   (`import = "nvchad.plugins"`) and one `{ import = "plugins.<group>" }` line per
   subdirectory (`ui`, `editing`, `lsp`, `dap`, `linting`, `tools`, `ai`) — lazy
   auto-discovers every spec file in those dirs (no hand-maintained manifest).
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
  languages.lua          per-language tooling registry — single source of truth (see below)
  utils.lua              shared helpers (tools_from_ft + the registry derivation fns)
  configs/
    lazy.lua             lazy.nvim setup table (UI, disabled rtp plugins)
    palette.lua          color table consumed by the snippets file
  snippets/              luasnip lua-snippet files (loaded via lua_snippets_path)
  plugins/
    ai/  dap/  editing/  linting/  lsp/  tools/  ui/   one spec (or list) per file;
                         every file is auto-imported (no manifest). Each subdir is
                         wired by a `{ import = "plugins.<group>" }` line in init.lua.
after/ftdetect/          custom filetype detection (strudel, terraform)
```

## Plugin wiring convention

There is **no manifest** — lazy auto-imports every `.lua` file under each `plugins/<group>/`
directory (one `{ import = "plugins.<group>" }` line per group in `init.lua`). **Dropping a
file in a group dir IS wiring it**; the file must `return` a spec table **or** a list of
specs (see `editing/mini.lua`, `dap/adapters.lua`, `tools/jupyter.lua`). There are no inline
specs scattered in an init file anymore — every plugin lives in its own file.

To disable a plugin, set `enabled = false` in its spec (see `editing/render-markdown.lua`,
`tools/strudel.lua`, `ui/tmuxline.lua`) — **never** delete the file's contents or rely on it
being "unreferenced", because auto-import has no concept of an orphan: any spec-returning
file in a group dir loads.

**Nested dirs:** lazy's importer is non-recursive — for a subdirectory it only loads that
subdir's `init.lua`. So `tools/overseer/` is wired via `tools/overseer/init.lua` (its
`templates/` dir is plain data the overseer config scans itself, NOT lazy specs).

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

`utils.formatters_by_ft(langs)` / `utils.linters_by_ft(langs)` / `utils.lsp_servers(langs)` —
derive conform's `formatters_by_ft`, nvim-lint's `linters_by_ft`, and the LSP server list from
the `lua/languages.lua` registry (schema in the registry section below). The first two share a
private `by_ft` core that **asserts on duplicate filetypes** (see collision guard below).

## Tooling pipelines

- **Formatting**: `editing/conform.lua` owns conform.nvim. `formatters_by_ft` is **derived
  from `lua/languages.lua`** (registry section below); it drives both formatting and (via
  `tools_from_ft`) mason-conform auto-install. format-on-save is on.
- **Linting**: `linting/linting.lua` owns nvim-lint + mason-nvim-lint; `linters_by_ft` is
  **derived from `lua/languages.lua`** the same way. (There is exactly ONE lint config —
  earlier duplicate files under `configs/` were dead and removed.)
- **LSP**: `lsp/lspconfig.lua` enables `extra_servers` (the pure LSP-only servers) **plus the
  servers derived from `lua/languages.lua`**, via `vim.lsp.enable`. Per-server overrides via
  `vim.lsp.config(name, {...})`. Mason provides the binaries.
- **Treesitter**: uses the **`main`** branch (not legacy `master`). Highlight + install are
  driven by NvChad's core; this file only extends the parser list and owns textobjects.
  Requires the `tree-sitter` CLI on PATH. Folds are native (`vim.treesitter.foldexpr` in
  `options.lua`).

## Per-language tooling registry (`lua/languages.lua`)

**Single source of truth for which tools a language uses.** Rather than repeat "python →
ruff / basedpyright / debugpy" across conform, nvim-lint, and lspconfig, each language is
declared **once** here and the three consumers derive their tables from it (via the
`utils.*_by_ft` / `utils.lsp_servers` helpers). Adding a language is a one-entry edit, not a
multi-file hunt.

The registry holds **routing only** — tool *names*, never tool *config*. Entries are keyed by
a logical language name; every field is optional:

| field        | type   | effect                                                          |
|--------------|--------|-----------------------------------------------------------------|
| `filetypes`  | list   | filetypes this entry applies to (**default `{ <key> }`**)       |
| `lsp`        | string | server name → added to `vim.lsp.enable`                         |
| `formatters` | list   | conform formatter names → `formatters_by_ft` for each filetype  |
| `linters`    | list   | nvim-lint linter names → `linters_by_ft` for each filetype      |
| `dap`        | `true` | label only — "this language has a debugger" (nothing reads it)  |

**What deliberately stays OUT of the registry:**

- **Tool *config*** (as opposed to names): basedpyright `settings`, golines `--max-len`,
  csharpier command, omnisharp handlers. These stay co-located in `conform.lua`'s
  `formatters = {}` block and `lspconfig.lua`'s `vim.lsp.config(name, {...})` calls. The
  registry *routes*; the consumer *configures*.
- **DAP specs.** lazy.nvim must own DAP plugin specs, so they live in
  `plugins/dap/adapters.lua`, never here. `dap = true` is just a label you keep in sync with
  that file by hand.
- **Pure LSP-only servers** (no formatter/linter/dap — e.g. graphql, terraformls, dartls,
  tailwindcss, ltex_plus, emmet_language_server). Those are not "languages"; they stay in the
  plain `extra_servers` list in `lspconfig.lua`. The registry is only for tooling-bearing
  languages.

**Filetypes are many-to-many — group entries by *uniform* tooling, not by language name.** An
entry applies its `formatters` AND `linters` to *all* its `filetypes`. When a formatter/server
spans several fts but the linters differ, **split into multiple entries**. Live example:
prettierd formats js/ts/jsx/tsx but eslint_d must run only on plain js/ts (not the react fts),
so there are two entries — `typescript` (`{ javascript, typescript }`, ts_ls + prettierd +
eslint_d) and `typescriptreact` (`{ javascriptreact, typescriptreact }`, prettierd only). A
server name only needs to appear once (`lsp_servers` dedups), so put `lsp = "ts_ls"` on just
one of the pair.

**Collision guard:** filetypes must be disjoint across entries for a given field. If two
entries both set `formatters` (or both `linters`) for the same ft, `utils.by_ft` **asserts at
startup** (loud error) instead of letting unspecified `pairs` order silently pick a winner and
drop a tool.

### Adding a language

1. Add one entry to `lua/languages.lua` with only the fields it needs.
2. Has a debugger? Add its adapter spec to `plugins/dap/adapters.lua` and set `dap = true`.
3. Needs tool *config* (server settings, formatter args)? Add it co-located in
   `conform.lua` / `lspconfig.lua` — NOT in the registry.
4. Purely an LSP with no formatter/linter/dap? It does NOT belong here — add the server name
   to `extra_servers` in `lspconfig.lua` instead.
5. Verify (below).

### Changing / removing a language

Edit or delete its registry entry; the three consumers update automatically. If removing
entirely, also remove the co-located bits (DAP spec, any tool-config overrides).

### Verifying a registry change

The resolved consumer tables must be exactly what you intend. Load the plugin headless and
inspect:

```sh
nvim --headless "+lua require('lazy').load{plugins={'conform.nvim'}}; print(vim.inspect(require'conform'.formatters_by_ft))" +qa
nvim --headless "+lua require('lazy').load{plugins={'mason-nvim-lint'}}; print(vim.inspect(require'lint'.linters_by_ft))" +qa
```

For a **behavior-preserving** edit, capture those *before* the change and diff after — or
`vim.deep_equal` the resolved table against a hand-written expected table. The LSP server set
is local to `lspconfig.lua`; to check it, stub `vim.lsp.enable` to capture its argument before
force-loading `nvim-lspconfig`.

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
- **Dead plugins → disable, don't delete.** A plugin you've stopped using gets
  `enabled = false` in its spec (kept as a self-documenting, re-enableable record), NOT
  removed. This overrides the general "delete dead code" leaning below — it applies
  specifically to plugin specs. Non-plugin dead code (stale helpers, superseded configs)
  may still be deleted rather than left as commented-out "graveyards."
- **Version control**: the user tracks this via a `git dotfiles` bare repo, not a `.git`
  here. Don't `git init`. Deletions are recoverable.

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
