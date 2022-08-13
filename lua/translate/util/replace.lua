local M = {
    before = {},
    after = {},
    translate_command = { "google", "deepl_free", "deepl_pro", "translate_shell" },
}

function M.setup()
    for _, cmd in ipairs(M.translate_command) do
        M["before"][cmd] = {}
        M["after"][cmd] = {}
    end

    -- put options: google、deepl_free、deepl_pro、translate_shell、all
    M.put_symbol_to_after("translate_shell", "u003d", "=")
    M.put_symbol_to_after("translate_shell", "＃", "#")
    M.put_symbol_to_before_and_after("translate_shell", "/", "{{@C@}}")
end

-- add character groups to the before dictionary of a specific translator
---@param command string
---@param char string
---@param rep string
function M.put_symbol_to_before(command, char, rep)
    if command == "all" then
        for _, cmd in ipairs(M.translate_command) do
            M["before"][cmd][char] = rep
        end
    else
        M["before"][command][char] = rep
    end
end

-- add character groups to the after dictionary of a specific translator
---@param command string
---@param char string
---@param rep string
function M.put_symbol_to_after(command, char, rep)
    if command == "all" then
        for _, cmd in ipairs(M.translate_command) do
            M["after"][cmd][char] = rep
        end
    else
        M["after"][command][char] = rep
    end
end

-- add character groups to the before and after dictionary of a specific translator
---@param command string
---@param char string
---@param rep string
function M.put_symbol_to_before_and_after(command, char, rep)
    if command == "all" then
        for _, cmd in ipairs(M.translate_command) do
            M["before"][cmd][char] = rep
            M["after"][cmd][rep] = char
        end
    else
        M["before"][command][char] = rep
        M["after"][command][rep] = char
    end
end

function M.run_before_replace_symbol(lines, pos)
    local cmd = require("translate.config").get_translate_command()
    for i, line in ipairs(lines) do
        for k, v in pairs(M["before"][cmd]) do
            if line:match(k) then
                lines[i] = line:gsub(k, v)
            end
        end
    end
    return lines
end

function M.run_after_replace_symbol(text, pos)
    local cmd = require("translate.config").get_translate_command()
    for k, v in pairs(M["after"][cmd]) do
        if text:match(k) then
            text = text:gsub(k, v)
        end
    end
    return text
end

return M
