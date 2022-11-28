local deepl = require("translate.preset.command.deepl")

local M = {}

---@param lines string[]
---@param command_args table
---@return string cmd
---@return string[] args
function M.cmd(lines, command_args)
  local url = "https://api.deepl.com/v2/translate"
  local cmd, args = deepl._cmd(url, lines, command_args)

  local options = require("translate.config").get("preset").command.deepl_pro
  if #options.args > 0 then
    args = vim.list_extend(args, options.args)
  end

  return cmd, args
end

M.complete_list = deepl.complete_list

return M
