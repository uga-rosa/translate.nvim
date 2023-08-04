local fn = vim.fn
local api = vim.api

local M = {}

function M.cmd(lines, pos)
  if type(lines) == "string" then
    lines = { lines }
  end

  local lines_origin = pos._lines

  -- Remain indentation
  for i, line in ipairs(lines) do
    local p = pos[i]
    local indent = string.rep(" ", #lines_origin[i]:sub(1, p.col[1] - 1))
    lines[i] = indent .. line
  end

  local option = require("translate.config").get("preset").output.split

  local size = M._get_size(#lines, option)

  local function split_win()
    local cmd = option.position == "bottom" and "botright" or "topleft"
    cmd = cmd .. " " .. size .. "new"
    vim.cmd(cmd)
  end

  local current_win_id = fn.win_getid()

  if fn.bufexists(option.name) == 1 then
    local bufnr = fn.bufnr(option.name)
    local winid = fn.win_findbuf(bufnr)
    -- Buffer is present, but window is closed
    if vim.tbl_isempty(winid) then
      split_win()
      vim.cmd("e " .. option.name)
    else
      fn.win_gotoid(winid[1])
    end
  else
    split_win()
    vim.cmd("e " .. option.name)
    api.nvim_set_option_value("buftype", "nofile", { buf = 0 })
    api.nvim_set_option_value("filetype", option.filetype, { buf = 0 })
  end

  if option.append and not M._buf_empty() then
    api.nvim_buf_set_lines(0, -1, -1, false, lines)
  else
    api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end

  -- Move cursor to bottom
  api.nvim_win_set_cursor(0, { fn.line("$"), 0 })

  fn.win_gotoid(current_win_id)
end

function M._buf_empty()
  if fn.line("$") ~= 1 then
    return false
  end

  local line = fn.getline(1)
  if line ~= "" then
    return false
  end

  return true
end

function M._get_size(size, option)
  local min_size = option.min_size
  if min_size < 1 then
    min_size = math.floor(api.nvim_win_get_height(0) * min_size)
  end
  local max_size = option.max_size
  if max_size < 1 then
    max_size = math.floor(api.nvim_win_get_height(0) * max_size)
  end

  if size <= min_size then
    return min_size
  end
  if size >= max_size then
    return max_size
  end
  return size
end

return M
