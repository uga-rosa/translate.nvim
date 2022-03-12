local api = vim.api
local utf8 = require("translate.util.utf8")

local M = {}

---Copy the table
---NOTE: Metatable is not considered
---@param tbl table
---@return table
function M.tbl_copy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local new = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            new[k] = M.tbl_copy(v)
        else
            new[k] = v
        end
    end
    return new
end

---Concatenate two list-like tables.
---@param t1 table
---@param t2 table
---@return table
function M.concat(t1, t2)
    local new = {}
    for _, v in ipairs(t1) do
        table.insert(new, v)
    end
    for _, v in ipairs(t2) do
        table.insert(new, v)
    end
    return new
end

---Add an element to dict[key]
---dict is a table with an array for values.
---@param dict {any: any[]}
---@param key any
---@param elem any
function M.append_dict_list(dict, key, elem)
    if not dict[key] then
        dict[key] = {}
    end
    table.insert(dict[key], elem)
end

function M.text_cut(text, widths)
    local widths_is_table = type(widths) == "table"

    local lines = {}
    local row, col = 1, 0
    for p, char in utf8.codes(text) do
        local l = api.nvim_strwidth(char)
        local width = widths_is_table and widths[row] or widths

        if col + l > width then
            if widths_is_table and widths[row + 1] == nil then
                local residue = text:sub(p)
                M.append_dict_list(lines, row, residue)
                break
            end

            row = row + 1
            col = 0
        end

        M.append_dict_list(lines, row, char)
        col = col + l
    end

    for i, line in ipairs(lines) do
        lines[i] = table.concat(line, "")
    end

    return lines
end

function M.max_width_in_string_list(list)
    local max = api.nvim_strwidth(list[1])
    for i = 2, #list do
        local v = api.nvim_strwidth(list[i])
        if v > max then
            max = v
        end
    end
    return max
end

function M.indent(pos)
    local indents = {}
    for _, line in ipairs(pos._lines) do
        local indent = line:match("^%s*")
        table.insert(indents, indent)
    end
    return indents
end

return M
