local luv = vim.loop

local config = require("translate.config")
local select = require("translate.util.select")

local M = {}

M.setup = config.setup

function M.translate(count, ...)
    vim.validate({
        count = { count, "number" },
    })

    local args = M._parse_args({ ... })

    local is_visual = count ~= 0
    local text, pos = select.get(args, is_visual)

    M._translate(text, pos, args)
end

function M._parse_args(opts)
    local args = {}
    for _, opt in ipairs(opts) do
        local name, arg = opt:match("-(%l+)=(.*)")
        if not name then
            name = opt:match("-(%l+)")
            if name then
                arg = true
            else
                name = "target"
                arg = opt
            end
        end
        args[name] = arg
    end
    return args
end

local function pipes()
    local stdin = luv.new_pipe(false)
    local stdout = luv.new_pipe(false)
    local stderr = luv.new_pipe(false)
    return { stdin, stdout, stderr }
end

function M._translate(text, pos, cmd_args)
    local command_func = config.get_command(cmd_args.command)
    local parse_func = config.get_parse(cmd_args.parse)
    local output_func = config.get_output(cmd_args.output)

    local cmd, args = command_func(text, cmd_args)
    local stdio = pipes()

    local handle
    handle = luv.spawn(cmd, { args = args, stdio = stdio }, function(code)
        if not config.get("silent") then
            if code == 0 then
                print("Translate success")
            else
                print("Translate failed")
            end
        end
    end)

    if not handle then
        return
    end

    luv.read_start(
        stdio[2],
        vim.schedule_wrap(function(err, data)
            assert(not err, err)

            if data then
                data = parse_func(data)
                output_func(data, pos)
            end
        end)
    )
end

return M
