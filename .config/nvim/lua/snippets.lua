local ls = require "luasnip"
local s = ls.snippet
local f = ls.function_node
local t = ls.text_node

local PALETTE = {
  bg = "#191813",
  surface = "#36342a",
  text = "#f9de74",
  accent = "#f9de74",
  inverse = "#36342a",
  error = "#f97478",
}

local function expand_color(_, snip)
  local key = snip.trigger:match "#([%w_]+)"
  return PALETTE[key] or snip.trigger
end

return {
  s({
    trig = "#[%w_]+",
    regTrig = true,
    wordTrig = false,
    priority = 1100,
  }, {
    f(expand_color, {}),
  }),

  s("lstest", {
    t "Luasnip custom file IS loading! Hooray!",
  }),
}
