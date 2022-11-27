local M = {}

---@param lines string[]
---@return string[]
function M.cmd(lines)
  local options = require("translate.config").get("preset").parse_before.concat
  local sep = options.sep
  lines = { table.concat(lines, sep) }

  return lines
end

return M
