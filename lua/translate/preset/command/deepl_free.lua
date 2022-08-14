local deepl = require("translate.preset.command.deepl")

local M = {}

---@param lines string[]
---@param command_args table
---@return string cmd
---@return string[] args
function M.cmd(lines, command_args)
    local url = "https://api-free.deepl.com/v2/translate"
    return deepl._cmd(url, lines, command_args)
end

M.complete_list = deepl.complete_list

return M
