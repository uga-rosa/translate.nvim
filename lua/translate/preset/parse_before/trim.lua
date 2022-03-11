local M = {}

function M.cmd(lines)
    -- local options = require("translate.config").get("preset").parse_before.trim
    for i, line in ipairs(lines) do
        lines[i] = vim.trim(line)
    end
    return lines
end

return M
