local M = {}

---@param lines string[]
---@param pos positions
---@return string[]
function M.cmd(lines, pos)
  for i, line in ipairs(lines) do
    local pre = line:match("^%s*")
    pos[i].col[1] = pos[i].col[1] + #pre

    local suf = line:match("%s*$")
    pos[i].col[2] = pos[i].col[2] - #suf

    lines[i] = line:sub(#pre + 1, -#suf - 1)
  end

  return lines
end

return M
