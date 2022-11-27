local api = vim.api

local util = require("translate.util.util")

local M = {}

---Cut the text to fit the window width.
---@param lines string[]
---@return string[]
function M.cmd(lines, _)
  local option = require("translate.config").get("preset").parse_after.window
  local width = option.width
  if width <= 1 then
    width = math.floor(api.nvim_win_get_width(0) * option.width)
  end

  local results = {}
  for _, text in ipairs(lines) do
    results = vim.list_extend(results, util.text_cut(text, width))
  end

  return results
end

return M
