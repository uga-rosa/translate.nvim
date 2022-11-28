local util = require("translate.util.util")

local M = {}

M.url =
  "https://script.google.com/macros/s/AKfycbxLRZgWI3UyHvHuYVyH1StiXbzJDHyibO5XpVZm5kMlXFlzaFVtLReR0ZteEkUbecRpPQ/exec"

---@param lines string[]
---@param command_args table
---@return string
---@return string[]
function M.cmd(lines, command_args)
  local data = vim.json.encode({
    text = lines,
    target = command_args.target,
    source = command_args.source,
  })
  local cmd, args
  if vim.fn.has("win32") == 1 then
    cmd = "cmd.exe"
    local path = util.write_temp_data(data)
    args = {
      "/c",
      table.concat({
        "curl",
        "-sL",
        M.url,
        "-d",
        "@" .. path,
      }, " "),
    }
  else
    cmd = "curl"
    args = {
      "-sL",
      M.url,
      "-d",
      data,
    }
  end

  local options = require("translate.config").get("preset").command.google
  if #options.args > 0 then
    args = vim.list_extend(args, options.args)
  end

  return cmd, args
end

function M.complete_list()
  -- See <https://cloud.google.com/translate/docs/languages>
  local list = {
    "af",
    "sq",
    "am",
    "ar",
    "hy",
    "az",
    "eu",
    "be",
    "bn",
    "bs",
    "bg",
    "ca",
    "ceb",
    "zh",
    "zh-CN",
    "zh-TW",
    "co",
    "hr",
    "cs",
    "da",
    "nl",
    "en",
    "eo",
    "et",
    "fi",
    "fr",
    "fy",
    "gl",
    "ka",
    "de",
    "el",
    "gu",
    "ht",
    "ha",
    "haw",
    "he",
    "iw",
    "hi",
    "hmn",
    "hu",
    "is",
    "ig",
    "id",
    "ga",
    "it",
    "ja",
    "jv",
    "kn",
    "kk",
    "km",
    "rw",
    "ko",
    "ku",
    "ky",
    "lo",
    "lv",
    "lt",
    "lb",
    "mk",
    "mg",
    "ms",
    "ml",
    "mt",
    "mi",
    "mr",
    "mn",
    "my",
    "ne",
    "no",
    "ny",
    "or",
    "ps",
    "fa",
    "pl",
    "pt",
    "pa",
    "ro",
    "ru",
    "sm",
    "gd",
    "sr",
    "st",
    "sn",
    "sd",
    "si",
    "sk",
    "sl",
    "so",
    "es",
    "su",
    "sw",
    "sv",
    "tl",
    "tg",
    "ta",
    "tt",
    "te",
    "th",
    "tr",
    "tk",
    "uk",
    "ur",
    "ug",
    "uz",
    "vi",
    "cy",
    "xh",
    "yi",
    "yo",
    "zu",
  }
  return list
end

return M
