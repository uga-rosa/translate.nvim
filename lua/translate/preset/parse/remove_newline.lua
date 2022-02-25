local M = {}

function M.cmd(text)
   text = text:gsub("[\r\n]", "")
   return text
end

return M
