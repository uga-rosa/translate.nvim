local M = {}

local json_decode = vim.json and vim.json.decode or vim.fn.json_decode

function M.cmd(response)
    response = json_decode(response)
    return response.translations[1].text
end

return M
