local api = vim.api

local M = {}

function M.cmd(lines, pos)
  if type(lines) == "string" then
    lines = { lines }
  end

  local lines_origin = pos._lines

  for i, line in ipairs(lines) do
    local p = pos[i]
    local indent = string.rep(" ", #lines_origin[i]:sub(1, p.col[1] - 1))
    lines[i] = indent .. line
  end

  local options = require("translate.config").get("preset").output.insert

  local row
  if options.base == "top" then
    row = pos[1].row
  else -- "bottom"
    row = pos[#pos].row
  end

  row = row + options.off

  api.nvim_buf_set_lines(0, row, row, false, lines)
end

return M
