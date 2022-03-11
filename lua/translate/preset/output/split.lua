local fn = vim.fn
local api = vim.api

local separate = require("translate.util.separate")

local M = {}

function M.cmd(text, pos)
    local options = require("translate.config").get("preset").output.split

    local lines
    if options.mode == "oneline" then
        lines = { text }
    elseif vim.tbl_contains({ "rate", "head" }, options.mode) then
        lines = separate.separate(options.mode, text, pos)
    else
        error(("Invalid mode of split: %s"):format(options.mode))
    end

    local current = fn.win_getid()

    if fn.bufexists(options.name) == 1 then
        local bufnr = fn.bufnr(options.name)
        local winid = fn.win_findbuf(bufnr)
        if vim.tbl_isempty(winid) then
            vim.cmd(options.cmd)
            vim.cmd("e " .. options.name)
        else
            fn.win_gotoid(winid[1])
        end
    else
        vim.cmd(options.cmd)
        vim.cmd("e " .. options.name)
        api.nvim_buf_set_option(0, "buftype", "nofile")
        vim.bo.filetype = options.filetype
    end

    if not options.append then
        vim.cmd("% d")
    end
    api.nvim_buf_set_lines(0, 0, 0, false, lines)

    -- Move cursor to top
    api.nvim_win_set_cursor(0, {1, 0})

    fn.win_gotoid(current)
end

return M
