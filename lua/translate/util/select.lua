local api = vim.api
local fn = vim.fn

local M = {}
local L = {}

function M.get(args, is_visual)
    if is_visual then
        return L.get_visual_selected()
    else
        return L.get_current_line()
    end
end

function L.get_visual_selected()
    local mode = fn.visualmode()

    local tl = fn.getpos("'<")
    local br = fn.getpos("'>")

    local lines = api.nvim_buf_get_lines(0, tl[2] - 1, br[2], true)

    local pos = {}
    pos._lines = lines
    pos._mode = mode

    if mode == "v" then
        for i, line in ipairs(lines) do
            pos[i] = { row = tl[2] + i - 1, col = { 1, #line } }
            if i == 1 then
                pos[i].col[1] = tl[3]
            end
            if i == #lines then
                pos[i].col[2] = br[3]
            end
        end
    elseif mode == "V" then
        for i, line in ipairs(lines) do
            pos[i] = { row = tl[2] + i - 1, col = { 1, #line } }
        end
    elseif mode == "" then
        for i, _ in ipairs(lines) do
            pos[i] = { row = tl[2] + i - 1, col = { tl[3], br[3] } }
        end
    end

    local text = {}
    for i, p in ipairs(pos) do
        text[i] = vim.trim(lines[i]:sub(p.col[1], p.col[2]))
    end
    text = table.concat(text, " ")

    return text, pos
end

function L.get_current_line()
    local line = api.nvim_get_current_line()
    local row = fn.line(".")
    local pos = { { row = row, col = { 1, #line } } }
    pos._lines = { line }
    pos._mode = "n"
    line = vim.trim(line)
    return line, pos
end

return M
