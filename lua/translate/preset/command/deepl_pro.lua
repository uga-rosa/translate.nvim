local M = {}

---@param text string|string[]
---@param command_args table
---@return string cmd
---@return table args
function M.cmd(text, command_args)
    if not vim.g.deepl_api_auth_key then
        error("[translate.nvim] Set your DeepL API authorization key to g:deepl_api_auth_key.")
    end

    local cmd = "curl"
    local args = {
        "-X",
        "POST",
        "-s",
        "https://api.deepl.com/v2/translate",
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

    local options = require("translate.config").get("preset").command["deepl_pro"]

    if #options.args > 0 then
        args = vim.list_extend(args, options.args)
    end

    return cmd, args
end

M.complete_list = require("translate.preset.command.deepl").complete_list

return M
