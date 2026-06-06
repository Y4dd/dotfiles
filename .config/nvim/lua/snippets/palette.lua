local ls = require "luasnip"
local s = ls.snippet
local f = ls.function_node
local t = ls.text_node
local palette = require "configs.palette"

local function expand_single_color_key(args)
  local key = args[2][1]
  if palette[key] then
    return palette[key]
  else
    return args[1][1]
  end
end

-- I don't understand any of this i used AI
return {
  s({
    trig = "#([%w_]+)",
    regTrig = true,
    wordTrig = false,
    priority = 1100,
  }, {
    f(expand_single_color_key, {}),
  }),
  s("lstest", {
    t "Luasnip custom file IS loading! Hooray!",
  }),
}
