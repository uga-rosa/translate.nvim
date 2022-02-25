local api = vim.api

local M = {}

function M.cmd(text, pos)
    local lines = {}
    local lines_origin = pos._lines
    local mode = pos._mode

    if mode == "n" then
        lines = { text }
    elseif mode == "v" then
        if #lines_origin == 1 then
            local col = pos[1].col
            local pre = lines_origin[1]:sub(1, col[1] - 1)
            local suf = lines_origin[1]:sub(col[2] + 1)
            lines = { pre .. text .. suf }
        else
            table.insert(lines, lines_origin[1]:sub(1, pos[1].col[1] - 1))
            table.insert(lines, text)
            table.insert(lines, lines_origin[#lines_origin]:sub(pos[#pos].col[2] + 1))
        end
    elseif mode == "V" then
        lines[1] = text
    else
        error("Don't use both CTRL_V and replace")
    end

    api.nvim_buf_set_lines(0, pos[1].row - 1, pos[#pos].row, true, lines)
end

return M
