local api = vim.api

local M = {}

function M.cmd(lines, pos)
  if type(lines) == "string" then
    lines = { lines }
  end

  local lines_origin = pos._lines

  for i, p in ipairs(pos) do
    local pre = lines_origin[i]:sub(1, p.col[1] - 1)
    local suf = lines_origin[i]:sub(p.col[2] + 1)

    lines[i] = pre .. (lines[i] or "") .. suf
  end

  api.nvim_buf_set_lines(0, pos[1].row - 1, pos[#pos].row, true, lines)
end

return M
