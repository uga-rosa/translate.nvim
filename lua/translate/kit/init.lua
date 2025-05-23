--[[
MIT License

Copyright (c) 2022 hrsh7th

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--

local kit = {}

---Create unique id.
---@return integer
kit.uuid = setmetatable({
  uuid = 0,
}, {
  __call = function(self)
    self.uuid = self.uuid + 1
    return self.uuid
  end,
})


-- https://neovim.io/doc/user/deprecated.html#vim.tbl_islist()
local islist = vim.islist or vim.tbl_islist

---Merge two tables.
---@generic T
---NOTE: This doesn't merge array-like table.
---@param tbl1 T
---@param tbl2 T
---@return T
function kit.merge(tbl1, tbl2)
  local is_dict1 = type(tbl1) == "table" and (not islist(tbl1) or vim.tbl_isempty(tbl1))
  local is_dict2 = type(tbl2) == "table" and (not islist(tbl2) or vim.tbl_isempty(tbl2))
  if is_dict1 and is_dict2 then
    local new_tbl = {}
    for k, v in pairs(tbl2) do
      if tbl1[k] ~= vim.NIL then
        new_tbl[k] = kit.merge(tbl1[k], v)
      end
    end
    for k, v in pairs(tbl1) do
      if tbl2[k] == nil then
        new_tbl[k] = v ~= vim.NIL and v or nil
      end
    end
    return new_tbl
  elseif is_dict1 and not is_dict2 then
    return kit.merge(tbl1, {})
  elseif not is_dict1 and is_dict2 then
    return kit.merge(tbl2, {})
  end

  if tbl1 == vim.NIL then
    return nil
  elseif tbl1 == nil then
    return tbl2
  else
    return tbl1
  end
end

---Concatenate two tables.
---NOTE: This doesn't concatenate dict-like table.
---@param tbl1 table
---@param tbl2 table
function kit.concat(tbl1, tbl2)
  local new_tbl = {}
  for _, item in ipairs(tbl1) do
    table.insert(new_tbl, item)
  end
  for _, item in ipairs(tbl2) do
    table.insert(new_tbl, item)
  end
  return new_tbl
end

---The value to array.
---@param value any
---@return table
function kit.to_array(value)
  if type(value) == "table" then
    if islist(value) or vim.tbl_isempty(value) then
      return value
    end
  end
  return { value }
end

---Check the value is array.
---@param value any
---@return boolean
function kit.is_array(value)
  return type(value) == "table" and (islist(value) or vim.tbl_isempty(value))
end

---Reverse the array.
---@param array table
---@return table
function kit.reverse(array)
  if not kit.is_array(array) then
    error("[kit] specified value is not an array.")
  end

  local new_array = {}
  for i = #array, 1, -1 do
    table.insert(new_array, array[i])
  end
  return new_array
end

---Map array values.
---@generic T
---@param array T[]
---@parma func fun(item: T, index: number): V
---@reutrn T[]
function kit.map(array, func)
  local new_array = {}
  for i, item in ipairs(array) do
    table.insert(new_array, func(item, i))
  end
  return new_array
end

return kit
