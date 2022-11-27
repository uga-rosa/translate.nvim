local M = {}

---@param lines string[]
---@return string[]
function M.cmd(lines, _)
  lines = { table.concat(lines, "") }
  return lines
end

return M
