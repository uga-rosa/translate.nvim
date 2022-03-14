local util = require("translate.util.util")

local M = {}

function M.cmd(lines, pos, cmd_args)
    local option = require("translate.config").get("preset").parse_before.natural

    local end_regex
    if cmd_args.source then
        local ends = M.get_end(cmd_args.source, option)
        if ends then
            end_regex = vim.regex([[\V\%(]] .. table.concat(ends, [[\|]]) .. [[\)\$]])
        end
    end

    pos._group = {}

    local results = {}
    local i, j = 1, 1
    while true do
        local line = lines[i]
        if not line then
            break
        end

        util.append_dict_list(results, j, line)
        util.append_dict_list(pos._group, j, i)

        i = i + 1
        local next_line = lines[i]
        if next_line == "" then
            j = j + 1
            util.append_dict_list(results, j, next_line)
            util.append_dict_list(pos._group, j, i)
            i = i + 1
            j = j + 1
        elseif end_regex and end_regex:match_str(line) then
            j = j + 1
        end
    end

    results = vim.tbl_map(function (r)
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
M.end_sentence = {
    english = {
        ".",
        "?",
        "!",
    },
    japanese = {
        "。",
        ".",
        "？",
        "?",
        "！",
        "!",
    },
    chinese = {
        "。",
        "！",
        "？",
        "：",
    },
}

function M.get_end(lang, option)
    lang = lang:lower()
    lang = option.lang_abbr[lang] or M.lang_abbr[lang]
    if option.end_sentence[lang] then
        return option.end_sentence[lang]
    elseif M.end_sentence[lang] then
        return M.end_sentence[lang]
    end
end

return M
