local helper = require('kit.helper')
local Syntax = require('___plugin_name___.kit.Vim.Syntax')

describe('kit.Vim.Syntax', function()

  before_each(function()
    vim.cmd([[
      enew!
      set filetype=vim
      call setline(1, ['let var = 1'])
    ]])
  end)

  it('should return vim syntax group', function()
    vim.cmd([[ syntax on ]])
    assert.are.same(Syntax.get_syntax_groups({ 0, 3 }), {})
    assert.are.same(Syntax.get_syntax_groups({ 0, 4 }), { 'Identifier' })
    assert.are.same(Syntax.get_syntax_groups({ 0, 6 }), { 'Identifier' })
    assert.are.same(Syntax.get_syntax_groups({ 0, 7 }), {})
  end)

  it('should return treesitter syntax group', function()
    helper.ensure_treesitter_parser('vim')
    vim.cmd([[ syntax off ]])
    assert.are.same(Syntax.get_syntax_groups({ 0, 3 }), {})
    assert.are.same(Syntax.get_syntax_groups({ 0, 4 }), { '@variable' })
    assert.are.same(Syntax.get_syntax_groups({ 0, 6 }), { '@variable' })
    assert.are.same(Syntax.get_syntax_groups({ 0, 7 }), {})
  end)

end)
