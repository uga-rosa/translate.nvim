local M = {}

function M.cmd(lines)
    local options = require("translate.config").get("preset").parse_before.concat
    local sep = options.sep
    return table.concat(lines, sep)
end

return M
