local M = {}

function M.cmd(lines, pos, _)
    for i, line in ipairs(lines) do
        if line:match("/") then
            lines[i] = line:gsub("/", "{{T-C}}")
        end
    end
    return lines
end

return M
