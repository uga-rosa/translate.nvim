local fn = vim.fn

local M = {}

---Set the register
---@param lines string[]
function M.cmd(lines, _)
    local text = table.concat(lines, "")

    local options = require("translate.config").get("preset").output.register
    local name = options.name

    fn.setreg(name, text)
end

return M
