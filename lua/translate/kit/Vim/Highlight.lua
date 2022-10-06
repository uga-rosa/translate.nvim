local kit = require('___plugin_name___.kit')
local Async = require('___plugin_name___.kit.Async')
local AsyncTask = require('___plugin_name___.kit.Async.AsyncTask')

local Highlight = {}

Highlight.namespace = vim.api.nvim_create_namespace('___plugin_name___.kit.Vim.Highlight')

---Blink specified range.
---@param range ___plugin_name___.kit.LSP.Range
---@param option? { delay: integer, count: integer }
---@return ___plugin_name___.kit.Async.AsyncTask
function Highlight.blink(range, option)
  option = kit.merge(option or {}, {
    delay = 150,
    count = 2,
  })

  local function timeout(timeout)
    return AsyncTask.new(function(resolve)
      vim.defer_fn(vim.schedule_wrap(resolve), timeout)
    end)
  end

  return Async.run(function()
    Async.await(timeout(option.delay * 1.2))
    for i = 1, option.count do
      vim.highlight.range(
        0,
        Highlight.namespace,
        'IncSearch',
        { range.start.line, range.start.character },
        { range['end'].line, range['end'].character },
        {}
      )
      Async.await(timeout(option.delay * 0.8))
      vim.api.nvim_buf_clear_namespace(0, Highlight.namespace, 0, -1)
      Async.await(timeout(option.delay))
    end
  end)
end

return Highlight

