local api = vim.api

local M = {}

function M.cmd(text, pos)
    local options = require("translate.config").get("preset").output.insert

    local row
    if options.base == "top" then
        row = pos[1].row
    else -- "bottom"
        row = pos[#pos].row
    end

    row = row + options.off

    api.nvim_buf_set_lines(0, row, row, false, { text })
end

return M
