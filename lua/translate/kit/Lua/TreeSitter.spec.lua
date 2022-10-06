---@diagnostic disable: need-check-nil, param-type-mismatch
local helper = require('kit.helper')
local TreeSitter = require('___plugin_name___.kit.Lua.TreeSitter')

describe('kit.Lua.TreeSitter', function()

  before_each(function()
    vim.cmd([[
      enew!
      syntax off
      set filetype=lua
      call setline(1, [
      \   'function A()',
      \   '  return 1',
      \   'end',
      \   'if "then" then',
      \   '  print(a())',
      \   'elseif "else if" then',
      \   '  print(a())',
      \   'elseif "else if" then',
      \   '  if "then" then',
      \   '    return 1',
      \   '  end',
      \   'else',
      \   '  print(a())',
      \   'end',
      \ ])
    ]])
  end)

  describe('get_next_leaf & get_prev_leaf', function()
    it('should return all leaves', function()
      local current, lines = nil, vim.api.nvim_buf_get_lines(0, 0, -1, false)

      current = TreeSitter.get_node_at(0, 0)
      local next_leaves = {}
      while current do
        table.insert(next_leaves, TreeSitter.get_node_text(current))
        current = TreeSitter.get_next_leaf(current)
      end

      current = TreeSitter.get_node_at(#lines - 1, #lines[#lines] - 1)
      local prev_leaves = {}
      while current do
        table.insert(prev_leaves, 1, TreeSitter.get_node_text(current))
        current = TreeSitter.get_prev_leaf(current)
      end

      assert.are.same(next_leaves, prev_leaves)
    end)
  end)

  describe('get_captures', function()
    it('should return all captured name', function()
      vim.treesitter.set_query('lua', 'pairs', [[
        [
          (function_declaration [
            ("function" @pair)
            ("end" @pair)
          ])
        ] @pair_context
      ]])
      local node = TreeSitter.get_node_at(0, 0)
      assert.is_true(TreeSitter.is_capture(vim.treesitter.get_query('lua', 'pairs'), node, 'pair'))
    end)
  end)

end)
