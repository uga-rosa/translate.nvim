local Highlight = require('___plugin_name___.kit.Vim.Highlight')

describe('kit.Vim.Highlight', function()

  it('should not throw error', function()
    Highlight.blink({
      start = { line = 0, character = 0 },
      ['end'] = { line = 0, character = 0 },
    }):sync()
  end)

end)

