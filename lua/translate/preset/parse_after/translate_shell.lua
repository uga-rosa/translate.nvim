local M = {}

---@param text string
---@return string[]
function M.cmd(text, _)
    local crlf
    -- Remove the extra CRLF at the end.
    if vim.endswith(text, "\r\n") then
        crlf = "\r\n"
        text = text:sub(1, -3)
    else
        crlf = text:sub(-1)
        text = text:sub(1, -2)
    end

    local lines = vim.split(text, crlf)

    for i, line in ipairs(lines) do
        if line:match("{{T%-C}}") then
            vim.pretty_print("yes")
            lines[i] = line:gsub("{{T%-C}}", "/")
        end
    end

    return lines
end

return M
