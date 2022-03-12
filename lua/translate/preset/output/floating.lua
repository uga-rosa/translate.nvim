local api = vim.api

local util = require("translate.util.util")

local M = {
    window = {},
}

function M.cmd(lines, _)
    if type(lines) == "string" then
        lines = { lines }
    end

    M.window.close()

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local options = require("translate.config").get("preset").output.floating

    options.width = util.max_width_in_string_list(lines)
    options.height = #lines

    local win = api.nvim_open_win(buf, false, options)

    M.window._current = { win = win, buf = buf }

    vim.cmd('au CursorMoved * ++once lua require("translate.preset.output.floating").window.close()')
end

function M.window.close()
    if M.window._current then
        api.nvim_win_close(M.window._current.win, false)
        api.nvim_buf_delete(M.window._current.buf, {})
        M.window._current = nil
    end
end

return M
