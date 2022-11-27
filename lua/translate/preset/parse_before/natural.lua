local util = require("translate.util.util")

local M = {}

local function inc(tbl, index)
  if tbl[index] then
    return index + 1
  end
  return index
end

---@param lines string[]
---@param pos positions
---@param cmd_args table
---@return string[]
function M.cmd(lines, pos, cmd_args)
  local option = require("translate.config").get("preset").parse_before.natural

  local end_regex
  local start_regex
  if cmd_args.source then
    local ends = M.get_end(cmd_args.source, option)
    if ends then
      end_regex = vim.regex([[\V\%(]] .. table.concat(ends, [[\|]]) .. [[\)\$]])
    end
    local starts = M.get_start(cmd_args.source, option)
    if starts then
      start_regex = vim.regex([[^\V\%(]] .. table.concat(starts, [[\|]]) .. [[\)]])
    end
  end

  pos._group = {}

  local results = {}
  local original_index, result_index = 1, 1

  while true do
    local line = lines[original_index]
    if not line then
      break
    end

    if line == "" then
      result_index = inc(results, result_index)
      util.append_dict_list(results, result_index, line)
      util.append_dict_list(pos._group, result_index, original_index)
      if results[result_index] then
        result_index = result_index + 1
      end
    else
      if start_regex and start_regex:match_str(line) then
        result_index = inc(results, result_index)
      end

      util.append_dict_list(results, result_index, line)
      util.append_dict_list(pos._group, result_index, original_index)

      if end_regex and end_regex:match_str(line) then
        result_index = inc(results, result_index)
      end
    end

    original_index = original_index + 1
  end

  results = vim.tbl_map(function(r)
    return table.concat(r, " ")
  end, results)

  return results
end

M.lang_abbr = {
  en = "english",
  eng = "english",
  ja = "japanese",
  jpn = "japanese",
  zh = "chinese",
  zho = "chinese",
  ["zh-CN"] = "chinese",
  ["zh-TW"] = "chinese",
}

-- vim's regex pattern (vary no magic '\V')
M.end_marks = {
  english = {
    ".",
    "?",
    "!",
    ":",
    ";",
  },
  japanese = {
    "。",
    ".",
    "？",
    "?",
    "！",
    "!",
    "：",
    "；",
  },
  chinese = {
    "。",
    "！",
    "？",
    "：",
  },
}

-- vim's regex pattern (vary no magic '\V')
M.start_marks = {
  english = {
    [[\u\U]],
  },
}

function M.get_end(lang, option)
  lang = lang:lower()
  lang = option.lang_abbr[lang] or M.lang_abbr[lang]
  return option.end_marks[lang] or M.end_marks[lang]
end

function M.get_start(lang, option)
  lang = lang:lower()
  lang = option.lang_abbr[lang] or M.lang_abbr[lang]
  return option.start_marks[lang] or M.start_marks[lang]
end

return M
