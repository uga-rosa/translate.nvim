local M = {}

M._preset = {
  parse_before = {
    natural = require("translate.preset.parse_before.natural"),
    trim = require("translate.preset.parse_before.trim"),
    concat = require("translate.preset.parse_before.concat"),
    no_handle = require("translate.preset.parse_before.no_handle"),
  },
  command = {
    translate_shell = require("translate.preset.command.translate_shell"),
    deepl_free = require("translate.preset.command.deepl_free"),
    deepl_pro = require("translate.preset.command.deepl_pro"),
    google = require("translate.preset.command.google"),
  },
  parse_after = {
    oneline = require("translate.preset.parse_after.oneline"),
    head = require("translate.preset.parse_after.head"),
    rate = require("translate.preset.parse_after.rate"),
    window = require("translate.preset.parse_after.window"),
    no_handle = require("translate.preset.parse_after.no_handle"),
    translate_shell = require("translate.preset.parse_after.translate_shell"),
    deepl_free = require("translate.preset.parse_after.deepl_free"),
    deepl_pro = require("translate.preset.parse_after.deepl_pro"),
    google = require("translate.preset.parse_after.google"),
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
    parse_before = "trim,natural",
    command = "google",
    parse_after = "head",
    output = "floating",
  },
  parse_before = {},
  command = {},
  parse_after = {},
  output = {},
  preset = {
    parse_before = {
      natural = {
        lang_abbr = {},
        end_marks = {},
        start_marks = {},
      },
      concat = {
        sep = " ",
      },
    },
    command = {
      google = {
        args = {},
      },
      translate_shell = {
        args = {},
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
        filetype = "translate",
        zindex = 50,
      },
      split = {
        position = "top",
        min_size = 3,
        max_size = 0.3,
        name = "translate://output",
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
  replace_symbols = {
    translate_shell = {
      ["="] = "{@E@}",
      ["#"] = "{@S@}",
      ["/"] = "{@C@}",
      ["\\n"] = "{@N@}",
    },
    deepl_free = {},
    deepl_pro = {},
    google = {},
  },
}

---@param opt table
function M.setup(opt)
  M.config = vim.tbl_deep_extend("force", M.config, opt)
end

---@param name string
---@return boolean|table
function M.get(name)
  return M.config[name]
end

---@param mode string
---@param name string
---@return fun(lines: string[], command_args: table)
---@return string
function M.get_func(mode, name)
  name = name or M.config.default[mode]
  local module = M.config[mode][name] or M._preset[mode][name]
  if module and module.cmd then
    return module.cmd, name
  else
    error(("Invalid name of %s: %s"):format(module, name))
  end
end

---@param mode string
---@param names string
---@return fun(text: string, command_args: table)[]
---@return string[]
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

---For completion of command ':Translate'
---@param mode string
---@return string[]
function M.get_keys(mode)
  local keys = vim.tbl_keys(M.config[mode])
  keys = vim.list_extend(keys, vim.tbl_keys(M._preset[mode]))
  return keys
end

return M
