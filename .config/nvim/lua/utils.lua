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

return M
