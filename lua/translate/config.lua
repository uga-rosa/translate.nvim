local M = {}

M._preset = {
    command = {
        translate_shell = require("translate.preset.command.translate_shell"),
        deepl_free = require("translate.preset.command.deepl_free"),
        deepl_pro = require("translate.preset.command.deepl_pro"),
    },
    parse = {
        remove_newline = require("translate.preset.parse.remove_newline"),
    },
    output = {
        floating = require("translate.preset.output.floating"),
        split = require("translate.preset.output.split"),
        insert = require("translate.preset.output.insert"),
        replace = require("translate.preset.output.replace"),
        register = require("translate.preset.output.register"),
    },
}

M.config = {
    default = {
        command = "translate_shell",
        parse = "remove_newline",
        output = "floating",
    },
    command = {},
    parse = {},
    output = {},
    preset = {
        command = {
            translate_shell = {
                args = { "-b", "-no-ansi" },
            },
            deepl_free = {
                args = {},
            },
            deepl_pro = {
                args = {},
            },
        },
        output = {
            floating = {
                relative = "cursor",
                style = "minimal",
                width = 0.8,
                row = 1,
                col = 1,
                border = "single",
            },
            split = {
                name = "translate://output",
                cmd = "topleft 5sp",
                filetype = "translate",
                append = false,
            },
            insert = {
                base = "bottom",
                off = 0,
            },
            replace = nil,
            register = {
                name = vim.v.register,
            },
        },
    },
    silent = false,
}

function M.setup(opt)
    M.config = vim.tbl_deep_extend("force", M.config, opt)
end

function M.get(name)
    return M.config[name]
end

local function _get(mode, name)
    name = name or M.config.default[mode]
    local module = M.config[mode][name] or M._preset[mode][name]
    if module then
        if module.cmd then
            return module.cmd
        end
        error(string.format("Invalid format (%s: %s): cannot find 'cmd'", mode, name))
    else
        error(string.format("Invalid %s: %s", mode, name))
    end
end

function M.get_command(name)
    return _get("command", name)
end

function M.get_parse(name)
    return _get("parse", name)
end

function M.get_output(name)
    return _get("output", name)
end

local function get_keys(mode)
    local keys = vim.tbl_keys(M.config[mode])
    keys = vim.list_extend(keys, vim.tbl_keys(M._preset[mode]))
    return keys
end

function M.get_complete_list(mode, cmdline)
    if vim.tbl_contains({ "command", "parse", "output" }, mode) then
        return get_keys(mode)
    elseif vim.tbl_contains({ "source", "target" }, mode) then
        local command = cmdline:match("-command=(%S*)")
        command = command or M.config.default.command

        command = M.config.command[command] or M._preset.command[command]
        if not command then
            return
        end

        local complete_list = command.complete_list
        if not complete_list then
            return
        end

        return complete_list(mode == "target")
    end
end

return M
