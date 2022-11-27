local M = {}

local json_decode = vim.json and vim.json.decode or vim.fn.json_decode

---@param response string #json string
---@return string[]
function M.cmd(response)
  local decoded = json_decode(response)
  local results = {}
  for _, r in ipairs(decoded.translations) do
    table.insert(results, r.text)
  end
  return results
end

return M
