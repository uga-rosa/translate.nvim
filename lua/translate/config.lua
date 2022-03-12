local M = {}

M._preset = {
    parse_before = {
        concat = require("translate.preset.parse_before.concat"),
        trim = require("translate.preset.parse_before.trim"),
    },
    command = {
        translate_shell = require("translate.preset.command.translate_shell"),
        deepl_free = require("translate.preset.command.deepl_free"),
        deepl_pro = require("translate.preset.command.deepl_pro"),
    },
    parse_after = {
        remove_newline = require("translate.preset.parse_after.remove_newline"),
        oneline = require("translate.preset.parse_after.oneline"),
        head = require("translate.preset.parse_after.head"),
        rate = require("translate.preset.parse_after.rate"),
        window = require("translate.preset.parse_after.window"),
        deepl = require("translate.preset.parse_after.deepl"),
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
        parse_before = "trim,concat",
        command = "translate_shell",
        parse_after = "remove_newline,window",
        output = "floating",
    },
    parse_before = {},
    command = {},
    parse_after = {},
    output = {},
    preset = {
        parse_before = {
            concat = {
                sep = " ",
            },
        },
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
        parse_after = {
            window = {
                width = 0.8,
            },
        },
        output = {
            floating = {
                relative = "cursor",
                style = "minimal",
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

function M.get_func(mode, name)
    name = name or M.config.default[mode]
    local module = M.config[mode][name] or M._preset[mode][name]
    if module and module.cmd then
        return module.cmd, name
    else
        error(("Invalid name of %s: %s"):format(module, name))
    end
end

function M.get_funcs(mode, names)
    names = names or M.config.default[mode]
    names = vim.split(names, ",")
    local modules = {}
    for _, name in ipairs(names) do
        local module = M.config[mode][name] or M._preset[mode][name]
        if module and module.cmd then
            table.insert(modules, module.cmd)
        else
            error(("Invalid name of %s: %s"):format(mode, name))
        end
    end
    return modules, names
end

-- For complete of command ':Translate'

local function get_keys(mode)
    local keys = vim.tbl_keys(M.config[mode])
    keys = vim.list_extend(keys, vim.tbl_keys(M._preset[mode]))
    return keys
end

function M.get_complete_list(mode, cmdline)
    if vim.tbl_contains({ "parse_before", "command", "parse_after", "output" }, mode) then
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
