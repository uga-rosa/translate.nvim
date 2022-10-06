local Range = require('___plugin_name___.kit.LSP.Range')

describe('kit.LSP.Range', function()

  it('should return the range is empty or not', function()
    local position1 = { line = 0, character = 0 }
    local position2 = { line = 0, character = 1 }
    assert.are.equal(Range.empty({ start = position1, ['end'] = position1 }), true)
    assert.are.equal(Range.empty({ start = position1, ['end'] = position2 }), false)
  end)

end)

