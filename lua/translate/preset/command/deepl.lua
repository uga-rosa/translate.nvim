local M = {}

---@param url string
---@param lines string[]
---@param command_args table
---@return string
---@return string[]
function M._cmd(url, lines, command_args)
    if not vim.g.deepl_api_auth_key then
        error("[translate.nvim] Set your DeepL API authorization key to g:deepl_api_auth_key.")
    end

    local cmd = "curl"
    local args = {
        "-X",
        "POST",
        "-s",
        url,
        "-d",
        "auth_key=" .. vim.g.deepl_api_auth_key,
        "-d",
        "target_lang=" .. command_args.target,
    }

    for _, t in ipairs(lines) do
        table.insert(args, "-d")
        table.insert(args, "text=" .. t)
    end

    if command_args.source then
        table.insert(args, "-d")
        table.insert(args, "source_lang" .. command_args.source)
    end

    local options = require("translate.config").get("preset").command["deepl_pro"]

    if #options.args > 0 then
        args = vim.list_extend(args, options.args)
    end

    return cmd, args
end

function M.complete_list(is_target)
    -- See <https://www.deepl.com/docs-api/translating-text/>
    local list = {
        "BG",
        "CS",
        "DA",
        "DE",
        "EL",
        "EN",
        "ES",
        "ET",
        "FI",
        "FR",
        "HU",
        "IT",
        "JA",
        "LT",
        "LV",
        "NL",
        "PL",
        "PT",
        "RO",
        "RU",
        "SK",
        "SL",
        "SV",
        "ZH",
    }

    if is_target then
        local append = {
            "EN-GB",
            "EN-US",
            "PT-PT",
            "PT-BR",
        }
        list = vim.list_extend(list, append)
    end

    return list
end

return M
