local Cache = require('___plugin_name___.kit.Cache')

describe('kit.Cache', function()

  it('should works {get,set,has,del}', function()
    local cache = Cache.new()
    assert.equal(cache:get('unknown'), nil)
    assert.equal(cache:has('unknown'), false)
    cache:set('known', nil)
    assert.equal(cache:get('known'), nil)
    assert.equal(cache:has('known'), true)
    cache:del('known')
    assert.equal(cache:get('known'), nil)
    assert.equal(cache:has('known'), false)
  end)

  it('should work ensure', function()
    local ensure = setmetatable({
      count = 0
    }, {
      __call = function(self)
        self.count = self.count + 1
      end
    })
    local cache = Cache.new()

    -- Ensure the value.
    assert.equal(cache:ensure('key', ensure), nil)
    assert.equal(cache:has('key'), true)
    assert.equal(ensure.count, 1)

    -- Doesn't call when the value was ensured.
    assert.equal(cache:ensure('key', ensure), nil)
    assert.equal(ensure.count, 1)


    -- Call after delete.
    cache:del('key')
    assert.equal(cache:ensure('key', ensure), nil)
    assert.equal(ensure.count, 2)
  end)

end)
