local Lua = require('___plugin_name___.kit.Lua')

---@class ___plugin_name___.kit.Async.AsyncTask<T>: { value: T }
---@field private value T
---@field private status ___plugin_name___.kit.Async.AsyncTask.Status
---@field private chained boolean
---@field private children (fun(): any)[]
local AsyncTask = {}
AsyncTask.__index = AsyncTask

---@alias ___plugin_name___.kit.Async.AsyncTask.Status integer
AsyncTask.Status = {}
AsyncTask.Status.Pending = 0
AsyncTask.Status.Fulfilled = 1
AsyncTask.Status.Rejected = 2

---Handle unhandled rejection.
---@param err any
function AsyncTask.on_unhandled_rejection(err)
  error(err)
end

---Return the value is AsyncTask or not.
---@param value any
---@return boolean
function AsyncTask.is(value)
  return getmetatable(value) == AsyncTask
end

---Resolve all tasks.
---@param tasks any[]
---@return ___plugin_name___.kit.Async.AsyncTask
function AsyncTask.all(tasks)
  return AsyncTask.new(function(resolve, reject)
    local values = {}
    local count = 0
    for i, task in ipairs(tasks) do
      AsyncTask.resolve(task):next(function(value)
        values[i] = value
        count = count + 1
        if #tasks == count then
          resolve(values)
        end
      end):catch(reject)
    end
  end)
end

---Create resolved AsyncTask.
---@param v any
---@return ___plugin_name___.kit.Async.AsyncTask
function AsyncTask.resolve(v)
  if AsyncTask.is(v) then
    return v
  end
  return AsyncTask.new(function(resolve)
    resolve(v)
  end)
end

---Create new AsyncTask.
---@NOET: The AsyncTask has similar interface to JavaScript Promise but the AsyncTask can be worked as synchronous.
---@param v any
---@return ___plugin_name___.kit.Async.AsyncTask
function AsyncTask.reject(v)
  if AsyncTask.is(v) then
    return v
  end
  return AsyncTask.new(function(_, reject)
    reject(v)
  end)
end

---Create new async task object.
---@generic T
---@param runner fun(resolve: fun(value: T), reject: fun(err: any))
function AsyncTask.new(runner)
  local self = setmetatable({}, AsyncTask)

  self.gc = Lua.gc(function()
    if self.status == AsyncTask.Status.Rejected then
      if not self.chained then
        AsyncTask.on_unhandled_rejection(self.value)
      end
    end
  end)

  self.value = nil
  self.status = AsyncTask.Status.Pending
  self.chained = false
  self.children = {}
  local ok, err = pcall(function()
    runner(function(res)
      if self.status ~= AsyncTask.Status.Pending then
        return
      end
      self.status = AsyncTask.Status.Fulfilled
      self.value = res
      for _, c in ipairs(self.children) do
        c()
      end
    end, function(err)
      if self.status ~= AsyncTask.Status.Pending then
        return
      end
      self.status = AsyncTask.Status.Rejected
      self.value = err
      for _, c in ipairs(self.children) do
        c()
      end
    end)
  end)
  if not ok then
    self.status = AsyncTask.Status.Rejected
    self.value = err
    for _, c in ipairs(self.children) do
      c()
    end
  end
  return self
end

---Sync async task.
---@NOTE: This method uses `vim.wait` so that this can't wait the typeahead to be empty.
---@param timeout? number
---@return any
function AsyncTask:sync(timeout)
  vim.wait(timeout or 24 * 60 * 60 * 1000, function()
    return self.status ~= AsyncTask.Status.Pending
  end, 0)
  if self.status == AsyncTask.Status.Rejected then
    error(self.value)
  end
  if self.status ~= AsyncTask.Status.Fulfilled then
    error('AsyncTask:sync is timeout.')
  end
  return self.value
end

---Register next step.
---@param on_fulfilled fun(value: any): any
function AsyncTask:next(on_fulfilled)
  return self:_dispatch(on_fulfilled, function(err)
    error(err)
  end)
end

---Register catch step.
---@param on_rejected fun(value: any): any
---@return ___plugin_name___.kit.Async.AsyncTask
function AsyncTask:catch(on_rejected)
  return self:_dispatch(function(value)
    return value
  end, on_rejected)
end

---Dispatch task state.
---@param on_fulfilled fun(value: any): any
---@param on_rejected fun(err: any): any
---@return ___plugin_name___.kit.Async.AsyncTask
function AsyncTask:_dispatch(on_fulfilled, on_rejected)
  self.chained = true
  local function dispatch(resolve, reject)
    if self.status == AsyncTask.Status.Fulfilled then
      local res = on_fulfilled(self.value)
      if AsyncTask.is(res) then
        res:next(resolve, reject)
      else
        resolve(res)
      end
    else
      local res = on_rejected(self.value)
      if AsyncTask.is(res) then
        res:next(resolve, reject)
      else
        resolve(res)
      end
    end
  end

  if self.status == AsyncTask.Status.Pending then
    return AsyncTask.new(function(resolve, reject)
      table.insert(self.children, function()
        dispatch(resolve, reject)
      end)
    end)
  end
  return AsyncTask.new(dispatch)
end

return AsyncTask
