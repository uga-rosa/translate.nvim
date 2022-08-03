local luv = vim.loop

local config = require("translate.config")
local select = require("translate.util.select")
local command = require("translate.command")

local M = {}

function M.translate(mode, args)
    vim.validate({
        mode = { mode, "string" },
    })

    args = M._parse_args(args)
    local pos = select.get(args, mode)

    if #pos == 0 then
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

local function set_to_top(tbl, elem)
    if tbl[1] ~= elem then
        table.insert(tbl, 1, elem)
    end
end

function M._translate(pos, cmd_args)
    local parse_before = config.get_funcs("parse_before", cmd_args.parse_before)
    local command, command_name = config.get_func("command", cmd_args.command)
    local parse_after = config.get_funcs("parse_after", cmd_args.parse_after)
    local output = config.get_func("output", cmd_args.output)

    if command_name == "deepl_pro" or command_name == "deepl_free" then
        set_to_top(parse_after, config._preset.parse_after.deepl.cmd)
    elseif command_name == "translate_shell" then
        set_to_top(parse_after, config._preset.parse_after.translate_shell.cmd)
    elseif command_name == "google" then
        set_to_top(parse_after, config._preset.parse_after.google.cmd)
    end

    local lines = M._selection(pos)
    pos._lines_selected = lines

    local text = M._run(parse_before, lines, pos, cmd_args)

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
        handle:close()
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

function M._run(functions, arg, pos, cmd_args)
    for _, func in ipairs(functions) do
        arg = func(arg, pos, cmd_args)
    end
    return arg
end

function M.setup(opt)
    config.setup(opt)
    command.create_command(M.translate)
end

return M
