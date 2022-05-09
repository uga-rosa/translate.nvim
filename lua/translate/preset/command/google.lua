local M = {}

M.url = "https://script.google.com/macros/s/AKfycbxLRZgWI3UyHvHuYVyH1StiXbzJDHyibO5XpVZm5kMlXFlzaFVtLReR0ZteEkUbecRpPQ/exec"

function M.cmd(text, command_args)
    local cmd = "curl"
    local args = {
        "-sL",
        M.url,
        "-d",
        vim.json.encode({
            text = text,
            target = command_args.target,
            source = command_args.source,
        })
    }
    return cmd, args
end

return M
