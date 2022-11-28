local fn = vim.fn

local config = require("translate.config")

local M = {}

local modes = {
  "parse_before",
  "command",
  "parse_after",
  "output",
  "source",
  "comment",
}

---@param arglead string #The leading portion of the argument currently being completed on
---@param cmdline string #The entire command line
---@param _ number #the cursor position in it (byte index)
---@return string[]?
function M.get_complete_list(arglead, cmdline, _)
  local mode
  if not vim.startswith(arglead, "-") then
    mode = "target"
  elseif arglead:find("^%-.*=") then
    mode = arglead:match("^%-(.*)=")
  else
    return modes
  end

  if vim.tbl_contains({ "parse_before", "command", "parse_after", "output" }, mode) then
    return config.get_keys(mode)
  elseif vim.tbl_contains({ "source", "target" }, mode) then
    local command = cmdline:match("-command=(%S+)")
    command = command or config.get("default").command
    local module = config.config.command[command] or config._preset.command[command]
    if module and module.complete_list then
      return module.complete_list(mode == "target")
    end
  end
end

---@param cb fun(mode: string, fargs: string[])
function M.create_command(cb)
  vim.api.nvim_create_user_command("Translate", function(opts)
    -- If range is 0, not given, it has been called from normal mode, or visual mode with `<Cmd>` mapping.
    -- Otherwise it must have been called from visual mode.
    local mode = opts.range == 0 and fn.mode() or fn.visualmode()
    cb(mode, opts.fargs)
  end, {
    range = 0,
    nargs = "+",
    complete = M.get_complete_list,
  })
end

return M
