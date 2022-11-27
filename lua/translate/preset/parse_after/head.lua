local api = vim.api

local util = require("translate.util.util")

local M = {}

---Cut the results of translation to fit the original width of the selection.
---The width of the last line cannot be guaranteed because the number of characters changes.
---@param lines string[]
---@param pos table
---@return string[]
function M.cmd(lines, pos)
  local results = {}

  for i, text in ipairs(lines) do
    local group = pos._group[i]

    local widths_origin = {}
    local sum_width_origin = 0
    for _, g in ipairs(group) do
      local width = api.nvim_strwidth(pos._lines_selected[g])
      table.insert(widths_origin, width)
      sum_width_origin = sum_width_origin + width
    end
    local sum_width_result = api.nvim_strwidth(text)

    local widths = widths_origin
    if sum_width_origin > sum_width_result then
      local l = sum_width_origin
      for j = #widths, 1, -1 do
        local w = widths[j]
        l = l - w
        if l >= sum_width_result then
          table.remove(widths, j)
        else
          widths[j] = sum_width_result - l
          break
        end
      end
    end

    if #widths > 1 then
      local result = util.text_cut(text, widths)
      local diff = #group - #widths
      if diff > 0 then
        for _ = 1, diff do
          table.insert(result, "")
        end
      end
      results = vim.list_extend(results, result)
    else
      table.insert(results, text)
    end
  end

  return results
end

return M
