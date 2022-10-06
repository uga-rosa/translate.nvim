local Lua = require('___plugin_name___.kit.Lua')

describe('kit.Lua', function()

  it('should detect gc timing.', function()
    local called = false
    local object = {
      marker = Lua.gc(function()
        called = true
      end)
    }
    object = nil
    collectgarbage('collect')
    assert.are.equals(object, nil)
    assert.are.equals(called, true)
  end)

end)
