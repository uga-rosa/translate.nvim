local api = vim.api

local util = require "translate.util.util"

local M = {}

function M.cmd(lines, pos)
    if type(lines) == "string" then
        lines = { lines }
    end

    local mode = pos._mode
    local indent = util.indent(pos)
    if mode == "n" or mode == "V" then
        for i = 1, #lines do
            lines[i] = indent .. lines[i]
        end
    elseif mode == "v" then
        local firstline_indent = indent .. string.rep(" ", #pos._lines[1]:sub(#indent + 1, pos[1].col[1] - 1))
        lines[1] = firstline_indent .. lines[1]
        for i = 2, #lines do
            lines[i] = indent .. lines[i]
        end
    end

    local options = require("translate.config").get("preset").output.insert

    local row
    if options.base == "top" then
        row = pos[1].row
    else -- "bottom"
        row = pos[#pos].row
    end

    row = row + options.off

    api.nvim_buf_set_lines(0, row, row, false, lines)
end

return M
