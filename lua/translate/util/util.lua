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

return M
