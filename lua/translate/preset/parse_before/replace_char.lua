local replace = require("translate.util.replace")

local M = {}

function M.cmd(lines, pos, _)
    return replace.run_before_replace_symbol(lines, pos)
end

return M
