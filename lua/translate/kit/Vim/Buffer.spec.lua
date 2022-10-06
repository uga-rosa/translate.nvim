local Buffer = require('___plugin_name___.kit.Vim.Buffer')

describe('kit.Vim.Buffer', function()

  before_each(function()
    vim.cmd([[
      enew!
      set noswapfile
    ]])
  end)

  it('should ensure bufnr via didn\'t loaded filename', function()
    local buf = Buffer.ensure(vim.api.nvim_get_runtime_file('syntax/markdown.vim', true)[1])
    assert.are.equal(vim.api.nvim_buf_get_option(buf, 'buflisted'), true)
    assert.are.equal(vim.api.nvim_buf_is_valid(buf), true)
    assert.are.equal(vim.api.nvim_buf_is_loaded(buf), true)
    assert.are.equal(#vim.api.nvim_buf_get_lines(buf, 0, -1, true), 169)
  end)

  it('should ensure bufnr via pseudo filename', function()
    local buf = Buffer.ensure('this-file-is-not-exists')
    assert.are.equal(vim.api.nvim_buf_get_option(buf, 'buflisted'), true)
    assert.are.equal(vim.api.nvim_buf_is_valid(buf), true)
    assert.are.equal(vim.api.nvim_buf_is_loaded(buf), true)
    assert.are.equal(#vim.api.nvim_buf_get_lines(buf, 0, -1, true), 1)
  end)

  it('should ensure bufnr via existing buffer', function()
    local org = vim.api.nvim_get_current_buf()
    local buf = Buffer.ensure(org)
    assert.are.equal(org, buf)
    assert.are.equal(vim.api.nvim_buf_get_option(buf, 'buflisted'), true)
    assert.are.equal(vim.api.nvim_buf_is_valid(buf), true)
    assert.are.equal(vim.api.nvim_buf_is_loaded(buf), true)
    assert.are.equal(#vim.api.nvim_buf_get_lines(buf, 0, -1, true), 1)
  end)

end)

