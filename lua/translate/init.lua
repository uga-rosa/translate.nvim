local luv = vim.loop

local config = require("translate.config")
local replace = require("translate.util.replace")
local select = require("translate.util.select")
local util = require("translate.util.util")
local create_command = require("translate.command").create_command

local M = {}

---@param mode string
---@param args string[]
function M.translate(mode, args)
  args = M._parse_args(args)
  local pos = select.get(args, mode)

  if #pos == 0 then
    vim.notify("Selection could not be recognized.")
    return
  end

  M._translate(pos, args)
end

---@param opts string[]
---@return table
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

---@param pos positions
---@param cmd_args table
function M._translate(pos, cmd_args)
  local parse_before = config.get_funcs("parse_before", cmd_args.parse_before)
  local command, command_name = config.get_func("command", cmd_args.command)
  local parse_after = config.get_funcs("parse_after", cmd_args.parse_after)
  local output = config.get_func("output", cmd_args.output)

  replace.set_command_name(command_name)
  set_to_top(parse_before, replace.before)
  set_to_top(parse_after, replace.after)

  local after_process = config._preset.parse_after[command_name]
  if after_process and after_process.cmd then
    set_to_top(parse_after, after_process.cmd)
  end

  local lines = M._selection(pos)
  pos._lines_selected = lines

  ---@type string[]
  lines = M._run(parse_before, lines, pos, cmd_args)
  if not pos._group then
    pos._group = util.seq(#lines)
  end

  local cmd, args = command(lines, cmd_args)
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
    vim.schedule_wrap(function(err, result)
      assert(not err, err)

      if result then
        result = M._run(parse_after, result, pos)
        output(result, pos)
      end
    end)
  )
end

---@param pos positions
---@return string[]
function M._selection(pos)
  local lines = {}
  for i, line in ipairs(pos._lines) do
    local col = pos[i].col
    table.insert(lines, line:sub(col[1], col[2]))
  end
  return lines
end

---@generic T
---@param functions function[]
---@param arg `T`
---@param pos positions
---@param cmd_args? string[]
---@return T
function M._run(functions, arg, pos, cmd_args)
  for _, func in ipairs(functions) do
    arg = func(arg, pos, cmd_args)
  end
  return arg
end

---@param opt table
function M.setup(opt)
  config.setup(opt)
  create_command(M.translate)
  vim.g.loaded_translate_nvim = true
end

return M
