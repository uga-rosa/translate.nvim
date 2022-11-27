local fn = vim.fn

local M = {}

---Set the register
---@param lines string[]
function M.cmd(lines, _)
  local newline
  local ff = vim.o.fileformat
  if ff == "unix" then
    newline = "\n"
  elseif ff == "dos" then
    newline = "\r\n"
  else
    newline = "\r"
  end

  local text = table.concat(lines, newline)

  local options = require("translate.config").get("preset").output.register
  local name = options.name

  fn.setreg(name, text)
end

return M
