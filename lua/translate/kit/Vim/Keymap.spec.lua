local Async = require('___plugin_name___.kit.Async')
local Keymap = require('___plugin_name___.kit.Vim.Keymap')

local async = Async.async
local await = Async.await

describe('kit.Vim.Keymap', function()

  it('should insert keysequence with async-await', function()
    vim.keymap.set('i', '<Plug>(kit.Vim.Keymap.send)', async(function()
      await(Keymap.send('foo', 'in'))
      await(Keymap.send('bar', 'in'))
      await(Keymap.send('baz', 'in'))
    end))
    Keymap.spec(async(function()
      await(Keymap.send(Keymap.termcodes('i{<Plug>(kit.Vim.Keymap.send)}'), 'i'))
    end))
    --NOTE: The `i` flag works only first time. 
    assert.are.equals(vim.api.nvim_get_current_line(), '{foo}barbaz')
  end)

end)
