local Position = require('___plugin_name___.kit.LSP.Position')

---@class ___plugin_name___.kit.LSP.Range
---@field public start ___plugin_name___.kit.LSP.Position
---@field public ['end'] ___plugin_name___.kit.LSP.Position

local Range = {}

---Return the value is range or not.
---@param v any
---@return boolean
function Range.is(range)
  return type(range) == 'table' and Position.is(range.start) and Position.is(range['end'])
end

---Return the range is empty or not.
---@param range ___plugin_name___.kit.LSP.Range
---@return boolean
function Range.empty(range)
  return range.start.line == range['end'].line and range.start.character == range['end'].character
end

---Convert range to utf8 from specified encoding.
---@param expr string|integer
---@param range ___plugin_name___.kit.LSP.Range
---@param from_encoding ___plugin_name___.kit.LSP.Position.Encoding
---@return ___plugin_name___.kit.LSP.Range
function Range.to_vim(expr, range, from_encoding)
  return {
    start = Position.to_vim(expr, range.start, from_encoding),
    ['end'] = Position.to_vim(expr, range['end'], from_encoding),
  }
end

return Range

