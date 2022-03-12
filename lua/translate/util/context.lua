local fn = vim.fn

local util = require("translate.util.util")

local M = {
    vim = {},
    ts = {},
}

---Get vim's syntax groups for specified position.
---NOTE: This function accepts 1-origin cursor position.
---@param cursor number[] @{lnum, col}
---@return string[]
function M.vim.get_range(group_name, cursor)
    if not M.vim.is_group(group_name, cursor) then
        return
    end

    -- Search start position
    local pos_s = util.tbl_copy(cursor)
    while true do
        local _pos_s = M.vim.jump(pos_s, 0)
        if _pos_s and M.vim.is_group(group_name, _pos_s) then
            pos_s = _pos_s
        else
            break
        end
    end

    -- Search end position
    local pos_e = util.tbl_copy(cursor)
    while true do
        local _pos_e = M.vim.jump(pos_e, 1)
        if _pos_e and M.vim.is_group(group_name, _pos_e) then
            pos_e = _pos_e
        else
            break
        end
    end

    local range = util.concat(pos_s, pos_e)
    return range
end

---Moves to the end of the next word or the beginning of the previous word.
---@param pos number[] @{ row, col }
---@param dir integer @if 0, next, otherwise previous
---@return number row, number col
function M.vim.jump(pos, dir)
    local row, col = pos[1], pos[2]
    local current_line = fn.getline(row)

    if dir == 0 then -- Head of previous word
        col = current_line:sub(1, col - 1):find("%S+%s*$")
        if not col then
            repeat
                row = row - 1
                if row < 1 then
                    return
                end
                current_line = fn.getline(row)
                col = current_line:find("%S+%s*$")
            until col
        end
    else -- Tail of next word
        local max_row = fn.line("$")

        _, col = current_line:find("%S+", col + 1)
        if not col then
            -- next not empty line
            repeat
                row = row + 1
                if row > max_row then
                    return
                end
                current_line = fn.getline(row)
                _, col = current_line:find("%S+")
            until col
        end
    end

    return { row, col }
end

function M.vim.is_group(group_name, pos)
    for _, syntax_id in ipairs(fn.synstack(pos[1], pos[2])) do
        if fn.synIDattr(fn.synIDtrans(syntax_id), "name") == group_name then
            return true
        end
    end
    return false
end

function M.ts.get_range(group_name, cursor)
    local name_range = M.ts.get_syntax_groups(cursor)
    return name_range[group_name]
end

---Get tree-sitter's syntax groups for specified position.
---NOTE: This function accepts 0-origin cursor position.
---@param pos number[]
---@return string[]
function M.ts.get_syntax_groups(pos)
    -- (1, 1) -> (0, 0)
    pos = vim.tbl_map(function(p)
        return p - 1
    end, pos)

    local bufnr = vim.api.nvim_get_current_buf()

    local highlighter = vim.treesitter.highlighter.active[bufnr]
    if not highlighter then
        return {}
    end

    local contains = function(node)
        local row_s, col_s, row_e, col_e = node:range()
        local contains = true
        contains = contains and (row_s < pos[1] or (row_s == pos[1] and col_s <= pos[2]))
        contains = contains and (pos[1] < row_e or (row_e == pos[1] and pos[2] < col_e))
        return contains
    end

    local name_range = {}

    highlighter.tree:for_each_tree(function(tstree, ltree)
        if not tstree then
            return
        end

        local root = tstree:root()
        if contains(root) then
            local query = highlighter:get_query(ltree:lang()):query()
            for id, node in query:iter_captures(root, bufnr, pos[1], pos[1] + 1) do
                if contains(node) then
                    local name = vim.treesitter.highlighter.hl_map[query.captures[id]]
                    if name then
                        local range = { node:range() }
                        -- (0, 0) -> (1, 1)
                        range = vim.tbl_map(function(r)
                            return r + 1
                        end, range)
                        name_range[name] = range
                    end
                end
            end
        end
    end)

    return name_range
end

return M
