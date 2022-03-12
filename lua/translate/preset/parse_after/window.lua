local api = vim.api

local util = require("translate.util.util")

local M = {}

function M.cmd(text, _)
    local option = require("translate.config").get("preset").parse_after.window
    local width = math.floor(api.nvim_win_get_width(0) * option.width)
    local lines = util.text_cut(text, width)

    return lines
end

return M
