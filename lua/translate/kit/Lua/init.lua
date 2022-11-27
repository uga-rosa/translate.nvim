local Lua = {}

---Create gabage collection detector.
---@param callback fun(...: any): any
---@return userdata
function Lua.gc(callback)
  local gc = newproxy(true)
  getmetatable(gc).__gc = callback
  return gc
end

return Lua
