local M = {}

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
