local fn = vim.fn
local api = vim.api

local utf8 = require("translate.util.utf8")
local util = require("translate.util.util")

local M = {}

function M.separate(sep_mode, text, pos)
    local width_origin = {}
    local sum_width_origin = 0
    for i, p in ipairs(pos) do
        local line_origin = pos._lines[i]
        local width = fn.strdisplaywidth(line_origin:sub(p.col[1], p.col[2]))
        table.insert(width_origin, width)
        sum_width_origin = sum_width_origin + width
    end
    local sum_width_result = fn.strdisplaywidth(text)

    local width = {}

    if sep_mode == "rate" then
        width = vim.tbl_map(function(w)
            return math.floor(w / sum_width_origin * sum_width_result)
        end, width_origin)
    elseif sep_mode == "head" then
        width = width_origin
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
    end

    local lines
    if #width > 1 then
        lines = M.text_cut(text, width)
    else
        lines = { text }
    end

    return lines
end

function M.text_cut(text, widths)
    local width_text = api.nvim_strwidth(text)

    if type(widths) == "number" then
        local _width = widths
        widths = {}
        local col_minus1 = math.floor(width_text / _width)
        for _ = 1, col_minus1 do
            table.insert(widths, _width)
        end
        table.insert(widths, width_text - _width * col_minus1)
    end

    local lines = {}
    local row, col = 1, 0
    for p, char in utf8.codes(text) do
        local l = api.nvim_strwidth(char)

        if col + l > widths[row] then
            if not widths[row + 1] then
                local residue = text:sub(p)
                util.append_dict_list(lines, row, residue)
                break
            end

            row = row + 1
            col = 0
        end

        util.append_dict_list(lines, row, char)
        col = col + l
    end

    for i, line in ipairs(lines) do
        lines[i] = table.concat(line, "")
    end

    return lines
end

return M
