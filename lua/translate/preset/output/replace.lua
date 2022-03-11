local api = vim.api

local separate = require("translate.util.separate")

local M = {}

function M.cmd(text, pos)
    local option = require("translate.config").get("preset").output.replace

    local lines = separate.separate(option.mode, text, pos)
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

    api.nvim_buf_set_lines(0, pos[1].row - 1, pos[#pos].row, true, lines)
end

return M
