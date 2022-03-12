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
    local pos = select.get(args, is_visual)

    if not pos then
        error("Selection could not be recognized.")
    end

    M._translate(pos, args)
end

function M._parse_args(opts)
    local args = {}
    for _, opt in ipairs(opts) do
        local name, arg = opt:match("-([a-z_]+)=(.*)") -- e.g. '-parse_after=head'
        if not name then
            name = opt:match("-(%l+)") -- for '-comment'
            if name then
                arg = true
            else -- '{target-lang}'
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

function M._translate(pos, cmd_args)
    local parse_before = config.get_funcs("parse_before", cmd_args.parse_before)
    local command, command_name = config.get_func("command", cmd_args.command)
    local parse_after, parse_after_name = config.get_funcs("parse_after", cmd_args.parse_after)
    local output = config.get_func("output", cmd_args.output)

    if vim.tbl_contains({ "deepl_pro", "deepl_free" }, command_name) and parse_after_name[1] ~= "deepl" then
        local parse_deepl = require("translate.preset.parse_after.deepl").cmd
        table.insert(parse_after, 1, parse_deepl)
    end

    local lines = M._selection(pos)

    local text = M._run(parse_before, lines)

    local cmd, args = command(text, cmd_args)
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
                data = M._run(parse_after, data, pos)
                output(data, pos)
            end
        end)
    )
end

function M._selection(pos)
    local lines = {}
    for i, line in ipairs(pos._lines) do
        local col = pos[i].col
        table.insert(lines, line:sub(col[1], col[2]))
    end
    return lines
end

function M._run(functions, arg, pos)
    for _, func in ipairs(functions) do
        arg = func(arg, pos)
    end
    return arg
end

return M
