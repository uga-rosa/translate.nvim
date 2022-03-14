local M = {}

function M.cmd(texts, _)
    texts = texts:gsub("[\n\r]+$", "")
    return vim.split(texts, "[\n\r]+")
end

return M
