local util = require("translate.util.util")

local M = {}

function M.cmd(lines, pos)
    pos._group = { util.seq(1, #lines) }

    local options = require("translate.config").get("preset").parse_before.concat
    local sep = options.sep
    lines = table.concat(lines, sep)

    return lines
end

return M
