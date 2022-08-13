local M = {}

function M.cmd(lines, pos, _)
    for i, line in ipairs(lines) do
        local slash = line:match("^/*")
        pos[i].col[1] = pos[i].col[1] + #slash

        lines[i] = line:sub(#slash + 1)
    end

    return lines
end

return M
