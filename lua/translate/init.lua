local api = vim.api
local fn = vim.fn
local luv = vim.loop

local config = require("translate.config")

local M = {}

M.setup = config.setup

function M.translate(count, ...)
    vim.validate({
        count = { count, "number" },
    })

    local is_visual = count ~= 0
    local text, pos = M._selected_text(is_visual)

    local args = M._parse_args({ ... })

    M._translate(text, pos, args)
end

function M._parse_args(opts)
    local args = {}
    for _, opt in ipairs(opts) do
        local name, arg = opt:match("-(%l+)=(.*)")
        if not name then
            name = "target"
            arg = opt
        end
        args[name] = arg
    end
    return args
end

function M._selected_text(is_visual)
    if not is_visual then
        local line = api.nvim_get_current_line()
        local row = fn.line(".")
        local pos = { { row = row, col = { 1, #line } } }
        pos._lines = { line }
        pos._mode = "n"
        return line, pos
    else
        local mode = vim.b.translate_old_mode

        local tl = fn.getpos("'<")
        local br = fn.getpos("'>")

        local lines = api.nvim_buf_get_lines(0, tl[2] - 1, br[2], true)

        local pos = {}
        pos._lines = lines
        pos._mode = mode

        if mode == "v" then
            for i, line in ipairs(lines) do
                pos[i] = { row = tl[2] + i - 1, col = { 1, #line } }
                if i == 1 then
                    pos[i].col[1] = tl[3]
                end
                if i == #lines then
                    pos[i].col[2] = br[3]
                end
            end
        elseif mode == "V" then
            for i, line in ipairs(lines) do
                pos[i] = { row = tl[2] + i - 1, col = { 1, #line } }
            end
        elseif mode == "" then
            for i, _ in ipairs(lines) do
                pos[i] = { row = tl[2] + i - 1, col = { tl[3], br[3] } }
            end
        end

        local text = {}
        for i, p in ipairs(pos) do
            text[i] = vim.trim(lines[i]:sub(p.col[1], p.col[2]))
        end
        text = table.concat(text, " ")

        return text, pos
    end
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
