local util = require "translate.util.util"
local api = vim.api

local M = {}

function M.cmd(lines, pos)
    if type(lines) == "string" then
        lines = { lines }
    end

    local lines_origin = pos._lines
    local mode = pos._mode

    if mode == "v" then
        local pre = lines_origin[1]:sub(1, pos[1].col[1] - 1)
        local suf = lines_origin[#lines_origin]:sub(pos[#pos].col[2] + 1)

        lines[1] = pre .. lines[1]
        lines[#lines] = lines[#lines] .. suf
    elseif mode == "" then
        for i, p in ipairs(pos) do
            local pre = lines_origin[i]:sub(1, p.col[1] - 1)
            local suf = lines_origin[i]:sub(p.col[2] + 1)

            lines[i] = pre .. (lines[i] or "") .. suf
        end
    end

    if mode == "n" or (mode == "v" and #lines > 1) or mode == "V" then
        local indents = util.indent(pos)
        local start_line = mode == "v" and 2 or 1
        for i = start_line, #lines do
            lines[i] = indents[i] .. lines[i]
        end
    end

    api.nvim_buf_set_lines(0, pos[1].row - 1, pos[#pos].row, true, lines)
end

return M
