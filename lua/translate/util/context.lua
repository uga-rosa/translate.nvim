local fn = vim.fn

local util = require("translate.util.util")
local TreeSitter = require("translate.kit.Lua.TreeSitter")

local M = {
  vim = {},
  ts = {},
}

---Get vim's syntax groups for specified position.
---NOTE: This function accepts 1-origin cursor position.
---@param cursor number[] @{lnum, col}
---@return string[]?
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
---@return { row: number, col: number }?
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

---Get tree-sitter's syntax groups for specified position.
---@param node_type string
---@param pos number[] (1,1)-index
---@return string[]? range
function M.ts.get_range(node_type, pos)
  local row, col = unpack(pos)
  -- (1, 1) -> (0, 0)
  row = row - 1
  col = col - 1

  local node = TreeSitter.get_node_at(row, col)
  if node == nil then
    return
  end
  local parents = TreeSitter.parents(node)
  for _, p_node in ipairs(parents) do
    if p_node:type() == node_type then
      local s_row, s_col, e_row, e_col = p_node:range()
      -- From 0-index to 1-index
      s_row = s_row + 1
      s_col = s_col + 1
      e_row = e_row + 1
      e_col = e_col + 1
      return { s_row, s_col, e_row, e_col }
    end
  end
end

return M
