local M = {}

function M.cmd(lines, pos)
    for i, line in ipairs(lines) do
        local pre = line:match("^%s*")
        if pre then
            pos[i].col[1] = pos[i].col[1] + #pre
        end

        local suf = line:match("%s*$")
        if suf then
            pos[i].col[2] = pos[i].col[2] - #suf
        end

        lines[i] = line:sub(#pre + 1, -#suf - 1)
    end

    return lines
end

return M
