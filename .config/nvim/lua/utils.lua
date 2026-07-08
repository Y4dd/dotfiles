local M = {}

-- Flatten a `*_by_ft` map ({ python = {"ruff"}, ... }) into a deduped list of
-- tool names, for mason `ensure_installed`.
M.tools_from_ft = function(by_ft)
  local set = {}
  for _, tools in pairs(by_ft) do
    for _, tool in ipairs(tools) do
      set[tool] = true
    end
  end
  return vim.tbl_keys(set)
end

-- Build a `{ ft -> {names} }` map from the language registry for a given field
-- ("formatters" or "linters"), expanding each language's `filetypes` (default
-- { <key> }). Shared core for the two by_ft helpers below. Filetypes must be
-- disjoint across registry entries for a given field: a collision is asserted
-- (loud startup error) rather than silently overwriting, since `pairs` order is
-- unspecified and a silent overwrite would quietly drop tools from the derived
-- table (and thus from mason `ensure_installed`).
local function by_ft(langs, field)
  local out = {}
  for name, lang in pairs(langs) do
    if lang[field] then
      for _, ft in ipairs(lang.filetypes or { name }) do
        assert(out[ft] == nil, ("languages.lua: two entries both set %s for filetype %q"):format(field, ft))
        out[ft] = lang[field]
      end
    end
  end
  return out
end

-- conform `formatters_by_ft`, derived from the registry.
M.formatters_by_ft = function(langs)
  return by_ft(langs, "formatters")
end

-- nvim-lint `linters_by_ft`, derived from the registry.
M.linters_by_ft = function(langs)
  return by_ft(langs, "linters")
end

-- Deduped list of LSP server names from the registry, for vim.lsp.enable.
M.lsp_servers = function(langs)
  local set, out = {}, {}
  for _, lang in pairs(langs) do
    if lang.lsp and not set[lang.lsp] then
      set[lang.lsp] = true
      out[#out + 1] = lang.lsp
    end
  end
  return out
end

return M
