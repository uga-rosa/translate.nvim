local M = {}

local function escape(text)
    text = text:gsub('"', '\\"')
    return text
end

local function _make_command(url, auth_key, text, command_args, options)
    local cmd = {
        "curl",
        "-s",
        url,
        "-d",
        ('"auth_key=%s"'):format(auth_key),
        "-d",
        ('"text=%s"'):format(escape(text)),
        "-d",
        ('"target_lang=%s"'):format(command_args.target),
    }

    if command_args.source then
        local append = { "-d", ('"source_lang=%s"'):format(command_args.source) }
        cmd = vim.list_extend(cmd, append)
    end

    if #options.args then
        cmd = vim.list_extend(cmd, options.args)
    end

    cmd = table.concat(cmd, " ")
    cmd = cmd .. " | jq -r .translations[].text"

    return cmd
end

function M.make_command(name)
    local url
    if name == "deepl_pro" then
        url = "https://api.deepl.com/v2/translate"
    elseif name == "deepl_free" then
        url = "https://api-free.deepl.com/v2/translate"
    end

    return function(text, command_args)
        if not vim.g.deepl_api_auth_key then
            error("[translate.nvim] Set your DeepL API authorization key to g:deepl_api_auth_key.")
        end

        local options = require("translate.config").get("preset").command[name]

        local cmd = "sh"
        local args = {
            "-c",
            _make_command(url, vim.g.deepl_api_auth_key, text, command_args, options),
        }

        return cmd, args
    end
end

function M.complete_list(is_to)
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

    if is_to then
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
