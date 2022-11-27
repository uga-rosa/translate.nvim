local api = vim.api

local util = require("translate.util.util")

local M = {}

---Cut the results of translation to fit the rate of the original width of the selection.
---@param lines string[]
---@param pos table
---@return string[]
function M.cmd(lines, pos)
  local results = {}

  for i, text in ipairs(lines) do
    local group = pos._group[i]

    local width_origin = {}
    local sum_width_origin = 0
    for _, g in ipairs(group) do
      local width = api.nvim_strwidth(pos._lines_selected[g])
      table.insert(width_origin, width)
      sum_width_origin = sum_width_origin + width
    end
    local sum_width_result = api.nvim_strwidth(text)

    local width = vim.tbl_map(function(w)
      return math.floor(w / sum_width_origin * sum_width_result)
    end, width_origin)

    if #width > 1 then
      results = vim.list_extend(results, util.text_cut(text, width))
    else
      table.insert(results, text)
    end
  end

  return results
end

return M
