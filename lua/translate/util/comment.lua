local fn = vim.fn
local api = vim.api

local context = require("translate.util.context")
local util = require("translate.util.util")

local M = {}

local string_symbols = {
  python = {
    { begin = [[''']], last = [[''']] },
    { begin = [["""]], last = [["""]] },
  },
}

function M.get_range() -- example 2. (see below)
  -- Common comments can be of the following types.
  -- 1. The comment string repeats at the start of each line (e.g. this line).
  --    This may be strung together on multiple lines to form a single comment.
  -- 2. Similar 1., but comments begin in the middle of the line (e.g. the comment four lines above).
  -- 3. three-piece comment (e.g. c's '/* comment */').
  --
  -- First, check to see if the current line is 1. by looking at the beginning of the line
  -- since the only case in which it is necessary to recursively examine is in 1.
  -- If not 1, then use highlighting or treesitter to take the range of comments.
  -- We have already established that it is either 2 or 3, so all that remains is to remove the comment sign.

  local comments = M.get_comments()

  -- (1, 1) indexed cursor position
  local cursor = api.nvim_win_get_cursor(0)
  cursor[2] = cursor[2] + 1

  local pos = {
    _mode = "comment",
  }

  if M.is_pattern1(comments, cursor[1], pos) then
    return pos
  end

  -- { row_s, col_s, row_e, col_e }
  local range = context.ts.get_range("comment", cursor) or context.vim.get_range("Comment", cursor)

  if range then
    M.remove_comment_symbol(comments, range, pos)
  else
    -- filetype check
    local ft = vim.bo.filetype
    if vim.tbl_contains(vim.tbl_keys(string_symbols), ft) then
      range = context.ts.get_range("string", cursor) or context.vim.get_range("String", cursor)
      if range then
        M.remove_string_symbol(string_symbols[ft], range, pos)
      end
    else
      vim.notify("Here is not in comments.")
    end
  end

  return pos
end

function M.get_comments()
  -- Ignore 'n' and 'f' because they are complicated and not used often.
  local comments = {}

  for comment in vim.gsplit(vim.bo.comments, ",") do
    local flags, com = comment:match("^(.*):(.*)$")

    if flags:find("b") then
      -- Blank required after com
      com = com .. [[\s]]
    end

    if flags:find("s") then
      -- Start of three-piece comment
      util.append_dict_list(comments, "s", com)
    elseif flags:find("m") then
      -- Middle of three-piece comment
      util.append_dict_list(comments, "m", com)
    elseif flags:find("e") then
      -- End of three-piece comment
      util.append_dict_list(comments, "e", com)
    elseif not flags:find("f") then
      -- When flags have none of the 'f', 's', 'm' or 'e' flags, Vim assumes the comment
      -- string repeats at the start of each line.  The flags field may be empty.
      util.append_dict_list(comments, "empty", com)
    end
  end

  comments = vim.tbl_map(function(c)
    return [[\V\%(]] .. table.concat(c, [[\|]]) .. [[\)]]
  end, comments)

  return comments
end

function M.remove_comment_symbol(comments, range, pos)
  local lines = api.nvim_buf_get_lines(0, range[1] - 1, range[3], true)
  pos._lines = lines

  if range[1] == range[3] and M.is_pattern2(comments, range, pos) then
    return pos
  end

  -- If you have made it this far, it should be pattern 3.
  -- So if it fails inside is_pattern3, it is an error.
  M.assert_pattern3(comments, range, pos)
  return pos
end

---Check if a line of 'row' is pattern 1, and if so, check if the lines above and below they are also pattern 1.
---Even if the pattern is 1, if the indentation and comment symbols are different, they are not considered to be
---in the same group.
---@param comments table
---@param row number
---@param pos table
---@return boolean is_pattern1
function M.is_pattern1(comments, row, pos)
  if not util.has_key(comments, "empty") then
    return false
  end

  local ok, col, prefix = M._is_pattern1(comments, row)
  if not ok then
    return false
  end

  table.insert(pos, { row = row, col = col })

  local function search(dir, border)
    local attention_row = row
    while true do
      attention_row = attention_row + dir
      if attention_row == border then
        break
      end
      ok, col = M._is_pattern1(comments, attention_row, prefix)
      if not ok then
        break
      end
      local p = { row = attention_row, col = col }
      if dir == -1 then
        table.insert(pos, 1, p)
      else
        table.insert(pos, p)
      end
    end
  end

  -- Search above
  search(-1, 1)

  -- Search below
  search(1, fn.line("$"))

  -- update
  pos._lines = api.nvim_buf_get_lines(0, pos[1].row - 1, pos[#pos].row, true)

  return true
end

---Checks if a line is pattern 1, and if so, returns the range removed indentation and
---comment string. If we already known a line is pattern 1, using 'prefix' to look for
---lines above and below it that begin with the same indentation and comment string.
---@param comments table
---@param row number
---@param prefix? string
---@return boolean? is_pattern1
---@return table? col
---@return string? prefix
function M._is_pattern1(comments, row, prefix)
  -- 1. the comment string repeats at the start of each line (e.g. this line)
  local line = fn.getline(row)
  if prefix then
    return vim.startswith(line, prefix), { #prefix + 1, #line }
  else
    local indent = [[^\V\s\*]]
    local col_s, col_e = vim.regex(indent .. comments.empty):match_line(0, row - 1)
    if col_s then
      prefix = line:sub(col_s, col_e)
      return true, { #prefix + 1, #line }, prefix
    end
  end
end

function M.is_pattern2(comments, range, pos)
  if not util.has_key(comments, "empty") then
    return false
  end

  local line = pos._lines[1]
  local comment = line:sub(range[2], range[4])
  local _, col_e = vim.regex("^" .. comments.empty):match_str(comment)
  if col_e then
    table.insert(pos, { row = range[1], col = { range[2] + col_e + 1, range[4] } })
    return true
  end
end

function M.assert_pattern3(comments, range, pos)
  if not util.has_key(comments, "s", "m", "e") then
    error("Invalid &comments")
  end

  -- like v selection
  for i, line in ipairs(pos._lines) do
    local indent = line:match("^%s*")
    local p = { row = range[1] + i - 1, col = { #indent + 1, #line } }
    table.insert(pos, p)
  end
  pos[1].col[1] = range[2]
  pos[#pos].col[2] = math.min(pos[#pos].col[2], range[4])

  -- Remove start of three-piece
  local first_line = pos._lines[1]:sub(range[2])
  if vim.regex("^" .. comments.s .. [[\s\*\$]]):match_str(first_line) then
    -- This line is unnecessary because it is only a comment string
    table.remove(pos, 1)
    table.remove(pos._lines, 1)
  else
    local _, num_of_com = vim.regex("^" .. comments.s):match_str(first_line)
    if num_of_com then
      pos[1].col[1] = pos[1].col[1] + num_of_com
    else
      error("The start of three-piece can't found")
    end
  end

  -- Remove middle of three-piece if exists
  if #pos > 2 then
    for i = 2, #pos do
      local selected = pos._lines[i]:sub(pos[i].col[1], pos[i].col[2])
      local _, num_of_com = vim.regex("^" .. comments.m):match_str(selected)
      -- In the case of the last line, end of three-piece may be misunderstood as middle of three-piece.
      if num_of_com and (i < #pos or not vim.regex("^" .. comments.e):match_str(selected)) then
        pos[i].col[1] = pos[i].col[1] - num_of_com
      end
    end
  end

  -- Remove end of three-piece
  local last_line = pos._lines[#pos._lines]:sub(1, range[4])
  if vim.regex([[^\V\s\*]] .. comments.e .. [[\$]]):match_str(last_line) then
    -- This line is unnecessary because it is only a comment string
    table.remove(pos, #pos)
    table.remove(pos._lines, #pos._lines)
  else
    local comStart, comEnd = vim.regex(comments.e .. [[\$]]):match_str(last_line)
    if comStart then
      local num_of_com = comEnd - comStart
      pos[#pos].col[2] = pos[#pos].col[2] - num_of_com
    else
      error("The end of three-piece can't found")
    end
  end
end

function M.remove_string_symbol(symbols, range, pos)
  local begin_row, last_row = range[1], range[3]
  local begin_col, last_col = range[2], range[4]

  local lines = api.nvim_buf_get_lines(0, begin_row - 1, last_row, true)
  pos._lines = lines

  for i, line in ipairs(lines) do
    pos[i] = { row = begin_row + i - 1, col = { 1, #line } }
  end
  pos[1].col[1] = begin_col
  pos[#pos].col[2] = last_col

  for _, s in ipairs(symbols) do
    if vim.startswith(lines[1]:sub(begin_col), s.begin) then
      pos[1].col[1] = pos[1].col[1] + #s.begin - 1
      pos[#pos].col[2] = pos[#pos].col[2] - #s.last
      if #pos >= 2 then
        local indent = lines[2]:match("^%s*")
        if #indent > 0 then
          for i = 2, #pos do
            pos[i].col[1] = #indent + 1
          end
        end
      end
      if pos[1].col[1] == pos[1].col[2] then
        table.remove(pos, 1)
        table.remove(pos._lines, 1)
      end
      if pos[#pos].col[1] == pos[#pos].col[2] then
        pos[#pos] = nil
        pos._lines[#pos._lines] = nil
      end
    end
  end
end

return M
