local M = {}

function M.make_command(name)
    local url
    if name == "deepl_pro" then
        url = "https://api.deepl.com/v2/translate"
    elseif name == "deepl_free" then
        url = "https://api-free.deepl.com/v2/translate"
    end

    ---@param text string|string[]
    ---@param command_args table
    ---@return string
    ---@return table
    return function(text, command_args)
        if not vim.g.deepl_api_auth_key then
            error("[translate.nvim] Set your DeepL API authorization key to g:deepl_api_auth_key.")
        end

        local options = require("translate.config").get("preset").command[name]

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

        text = type(text) == "table" and text or { text }
        for _, t in ipairs(text) do
            table.insert(args, "-d")
            table.insert(args, "text=" .. t)
        end

        if command_args.source then
            table.insert(args, "-d")
            table.insert(args, "source_lang" .. command_args.source)
        end

        if #options.args > 0 then
            args = vim.list_extend(args, options.args)
        end

        return cmd, args
    end
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
