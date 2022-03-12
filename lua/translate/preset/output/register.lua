local fn = vim.fn

local M = {}

function M.cmd(text, _)
    if type(text) == "table" then
        text = table.concat(text, "")
    end

    local options = require("translate.config").get("preset").output.register
    local name = options.name

    fn.setreg(name, text)
end

return M
