local M = {}

function M.cmd(lines)
    for i, line in ipairs(lines) do
        lines[i] = vim.trim(line)
    end
    return lines
end

return M
