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

  local options = require("translate.config").get("preset").output.floating

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  api.nvim_set_option_value("filetype", options.filetype, { buf = buf })

  local width = util.max_width_in_string_list(lines)
  local height = #lines

  local win = api.nvim_open_win(buf, false, {
    relative = options.relative,
    style = options.style,
    width = width,
    height = height,
    row = options.row,
    col = options.col,
    border = options.border,
    zindex = options.zindex,
  })

  M.window._current = { win = win, buf = buf }

  api.nvim_create_autocmd("CursorMoved", {
    callback = M.window.close,
    once = true,
  })
end

function M.window.close()
  if M.window._current then
    api.nvim_win_close(M.window._current.win, false)
    api.nvim_buf_delete(M.window._current.buf, {})
    M.window._current = nil
  end
end

return M
