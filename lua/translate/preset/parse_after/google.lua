local M = {}

function M.cmd(text, _)
  return vim.json.decode(text)
end

return M
