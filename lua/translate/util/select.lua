local api = vim.api
local fn = vim.fn

local comment = require("translate.util.comment")
local utf8 = require("translate.util.utf8")
local util = require("translate.util.util")

local M = {}
local L = {}

---@class position
---@field row integer
---@field col integer[] { begin, last }

---@class positions
---@field _lines string[]
---@field _mode "comment" | "n" | "v" | "V" | ""
---@field [1] position[]

---@param args table
---@param mode string
---@return positions
function M.get(args, mode)
  if args.comment then
    return comment.get_range()
  elseif mode == "n" then
    return L.get_current_line()
  else
    return L.get_visual_selected(mode)
  end
end

---@param mode string
---@return positions
function L.get_visual_selected(mode)
  local start, last
  -- When called from command line, "v" and "." return the same locations (cursor position, not selection range).
  -- In this case, '< and '> must be used.
  if util.same_pos(".", "v") then
    start = util.getpos("'<")
    last = util.getpos("'>")
  else
    start = util.getpos("v")
    last = util.getpos(".")
  end

  local pos_s, pos_e = util.which_front(start, last)

  local lines = api.nvim_buf_get_lines(0, pos_s[1] - 1, pos_e[1], true)

  local pos = {}
  pos._lines = lines
  pos._mode = mode

  if mode == "V" then
    for i, line in ipairs(lines) do
      table.insert(pos, { row = pos_s[1] + i - 1, col = { 1, #line } })
    end
  else
    local last_line = fn.getline(pos_e[1])
    local is_end = pos_e[2] == #last_line + 1 -- Selected to the end of each line.
    if not is_end then
      local offset = utf8.offset(last_line, 2, pos_e[2])
      if offset then
        pos_e[2] = offset - 1
      else -- The last character of the line.
        pos_e[2] = #last_line
      end
    end

    if mode == "v" then
      for i, line in ipairs(lines) do
        local p = { row = pos_s[1] + i - 1, col = { 1, #line } }
        table.insert(pos, p)
      end
      pos[1].col[1] = pos_s[2]
      pos[#pos].col[2] = pos_e[2]
    elseif mode == "" then
      for i, _ in ipairs(lines) do
        local row = pos_s[1] + i - 1
        local col_end = is_end and #fn.getline(row) or pos_e[2]
        table.insert(pos, { row = row, col = { pos_s[2], col_end } })
      end
    end
  end

  return pos
end

---@return positions
function L.get_current_line()
  local row = fn.line(".")
  local line = api.nvim_get_current_line()
  local pos = { { row = row, col = { 1, #line } } }
  pos._lines = { line }
  pos._mode = "n"
  return pos
end

return M
