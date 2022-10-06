local Buffer = require('___plugin_name___.kit.Vim.Buffer')

---@class ___plugin_name___.kit.LSP.Position
---@field public line integer
---@field public character integer

local Position = {}

---@alias ___plugin_name___.kit.LSP.Position.Encoding 'utf8'|'utf16'|'utf32'
Position.Encoding = {}
Position.Encoding.UTF8 = 'utf8'
Position.Encoding.UTF16 = 'utf16'
Position.Encoding.UTF32 = 'utf32'

---Return the value is position or not.
---@param v any
---@return boolean
function Position.is(v)
  return type(v) == 'table' and type(v.line) == 'number' and type(v.character) == 'number'
end

---Create cursor position.
---@param encoding ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Position
function Position.cursor(encoding)
  encoding = encoding or Position.Encoding.UTF16
  local cursor = vim.api.nvim_win_get_cursor(0)
  local text = vim.api.nvim_get_current_line()

  local utf8 = { line = cursor[1] - 1, character = cursor[2] }
  if encoding == Position.Encoding.UTF8 then
    return utf8
  elseif encoding == Position.Encoding.UTF16 then
    return Position.to_utf16(text, utf8, Position.Encoding.UTF8)
  elseif encoding == Position.Encoding.UTF32 then
    return Position.to_utf32(text, utf8, Position.Encoding.UTF8)
  end
end

---Convert position to utf8 from specified encoding.
---@param expr string|integer
---@param position ___plugin_name___.kit.LSP.Position
---@param from_encoding ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Position
function Position.to_vim(expr, position, from_encoding)
  if from_encoding == Position.Encoding.UTF8 then
    return position
  end
  local text = Buffer.at(expr, position.line)
  if from_encoding == Position.Encoding.UTF16 then
    return Position.to_utf8(text, position, Position.Encoding.UTF16)
  elseif from_encoding == Position.Encoding.UTF32 then
    return Position.to_utf8(text, position, Position.Encoding.UTF32)
  end
end

---Convert position to utf8 from specified encoding.
---@param text string
---@param position ___plugin_name___.kit.LSP.Position
---@param from_encoding? ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Position
function Position.to_utf8(text, position, from_encoding)
  from_encoding = from_encoding or Position.Encoding.UTF16

  if from_encoding == Position.Encoding.UTF8 then
    return position
  end

  local ok, byteindex = pcall(function()
    return vim.str_byteindex(text, position.character, from_encoding == Position.Encoding.UTF16)
  end)
  if not ok then
    return position
  end
  return { line = position.line, character = byteindex }
end

---Convert position to utf16 from specified encoding.
---@param text string
---@param position ___plugin_name___.kit.LSP.Position
---@param from_encoding? ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Position
function Position.to_utf16(text, position, from_encoding)
  local utf8 = Position.to_utf8(text, position, from_encoding)
  for index = utf8.character, 0, -1 do
    local ok, utf16index = pcall(function()
      return select(2, vim.str_utfindex(text, index))
    end)
    if ok then
      return { line = utf8.line, character = utf16index }
    end
  end
  return position
end

---Convert position to utf32 from specified encoding.
---@param text string
---@param position ___plugin_name___.kit.LSP.Position
---@param from_encoding? ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Position
function Position.to_utf32(text, position, from_encoding)
  local utf8 = Position.to_utf8(text, position, from_encoding)
  for index = utf8.character, 0, -1 do
    local ok, utf32index = pcall(function()
      return select(1, vim.str_utfindex(text, index))
    end)
    if ok then
      return { line = utf8.line, character = utf32index }
    end
  end
  return position
end

return Position
