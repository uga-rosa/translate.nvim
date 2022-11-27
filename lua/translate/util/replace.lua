local config = require("translate.config")

local M = {
  command_name = "",
}

---@param command_name string
function M.set_command_name(command_name)
  M.command_name = command_name
end

---@param lines string[]
---@param is_before boolean
---@return string[]
local function replace(lines, is_before)
  local replace_symbols = config.get("replace_symbols") or {}
  local symbols = replace_symbols[M.command_name]
  if symbols and next(symbols) ~= nil then
    for i, line in ipairs(lines) do
      for org, rep in pairs(symbols) do
        if is_before then
          line = line:gsub(org, rep)
        else
          line = line:gsub(rep, org)
        end
      end
      lines[i] = line
    end
  end
  return lines
end

---@param lines string[]
---@return string[]
function M.before(lines)
  return replace(lines, true)
end

---@param lines string[] | string
---@return string[]
function M.after(lines)
  if type(lines) == "string" then
    lines = { lines }
  end
  return replace(lines, false)
end

return M
