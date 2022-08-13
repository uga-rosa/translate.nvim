local replace = require("translate.util.replace")

local M = {}

function M.cmd(text, pos, _)
    return replace.run_after_replace_symbol(text, pos)
end

return M
