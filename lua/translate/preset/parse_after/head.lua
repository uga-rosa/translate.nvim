local fn = vim.fn

local util = require("translate.util.util")

local M = {}

function M.cmd(text, pos)
    local width_origin = {}
    local sum_width_origin = 0
    for i, p in ipairs(pos) do
        local line_origin = pos._lines[i]
        local width = fn.strdisplaywidth(line_origin:sub(p.col[1], p.col[2]))
        table.insert(width_origin, width)
        sum_width_origin = sum_width_origin + width
    end
    local sum_width_result = fn.strdisplaywidth(text)

    local width = width_origin
    if sum_width_origin > sum_width_result then
        local l = sum_width_origin
        for i = #width, 1, -1 do
            local w = width[i]
            l = l - w
            if l >= sum_width_result then
                table.remove(width, i)
            else
                width[i] = sum_width_result - l
                break
            end
        end
    end

    local lines
    if #width > 1 then
        lines = util.text_cut(text, width)
    else
        lines = { text }
    end

    return lines
end

return M
