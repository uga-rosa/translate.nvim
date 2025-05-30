local M = {}

local json_encode = vim.json and vim.json.encode or vim.fn.json_encode

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
    "--header",
    "Content-Type: application/json",
    "--header",
    "Authorization: DeepL-Auth-Key " .. vim.g.deepl_api_auth_key,
    "--data",
    json_encode({
      text = lines,
      target_lang = command_args.target,
      source_lang = command_args.source,
    })
  }

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
