local Async = require('___plugin_name___.kit.Async')
local AsyncTask = require('___plugin_name___.kit.Async.AsyncTask')

local async = Async.async
local await = Async.await

describe('kit.Async', function()

  it('should work like JavaScript Promise', function()
    local multiply = async(function(v)
      return AsyncTask.new(function(resolve)
        vim.schedule(function()
          resolve(v * v)
        end)
      end)
    end)
    local num = async(function()
      local num = 2
      num = await(multiply(num))
      num = await(multiply(num))
      return num
    end)():sync()
    assert.are.equal(num, 16)
  end)

end)
