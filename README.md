# translate.nvim

![demo](https://user-images.githubusercontent.com/82267684/158013979-52c8ca49-84e1-4ca0-bf30-b8165cca9135.gif)

# Features

- You can use any command you like for translation.
    - Google translate API (default)
    - [translate-shell](https://github.com/soimort/translate-shell)
    - [DeepL API Pro/Free](https://www.deepl.com/en/docs-api/)
- The results of the translation can be output in a variety of ways.
    - Floating window
    - Split window
    - Insert to the current buffer
    - Replace the original text
    - Set the register
- The translation command and output method can be specified as command arguments.
- In addition to the above presets, you can add your own functions.


# Requirements

- neovim 0.8+

The default Google Translate requires nothing but [curl](https://curl.se/).

If you use [translate-shell](https://github.com/soimort/translate-shell), you need to install `trans` command.

If you use [DeepL API Pro/Free](https://www.deepl.com/en/docs-api/), you need the authorization key for DeepL API Pro/Free.
In addition, you need curl to send the request.


# Quick start

## Install

With any plugin manager you like (e.g. [vim-plug](https://github.com/junegunn/vim-plug), [packer.nvim](https://github.com/wbthomason/packer.nvim), [dein.vim](https://github.com/Shougo/dein.vim))

## Setup

This plugin has default settings, so there is no need to call setup if you want to use it as is.

This is my setting.

```lua
vim.g.deepl_api_auth_key = "MY_AUTH_KEY"

require("translate").setup({
    default = {
        command = "deepl_pro",
    },
    preset = {
        output = {
            split = {
                append = true,
            },
        },
    },
})
```

See help for available options.

## Command

This plugin provides `:Translate`.

I put the quote from the help in the fold.

<details><summary>:Translate</summary><div>


    :[range]Translate {target-lang} [{-options}...]

        {target-lang}: Required. The language into which the text should be
        translated. The format varies depending on the external command used.

        |:Translate| can take |:range|. |v|, |V| and |CTRL-V| are supported. If it was
        not given, |:Translate| treats current cursor line.

        available options:
            - '-source='
                The language of the text to be translated.
            - '-parse_before='
                The functions to format texts of selection. You can
                use a comma-separated string. If omitted,
                |translate-nvim-option-default-parse-before|.
            - '-command='
                The extermal command to use translation. If omitted,
                |translate-nvim-option-default-command| is used.
            - '-parse_after='
                The functions to format the result of extermal
                command. You can use a comma-separated string.
                If omitted, |translate-nvim-option-default-parse-after|.
            - '-output='
                The function to pass the translation result. If
                omitted, |translate-nvim-option-default-output|.
            - '-comment'
                Special option, used as a flag. If this flag is set
                and the cursor is over a comment, whole comment is
                treated as a selection.


        Use <Cmd> for mapping.
        If you cannot use it, you must change the format with nmap and xmap.


        nnoremap me <Cmd>Translate EN<CR>
        xnoremap me <Cmd>Translate EN<CR>
        
        Another way.

        nnoremap me :<C-u>Translate EN<CR>
        xnoremap me :Translate EN<CR>


</div></details>


# Translate the word under the cursor

You can use this mapping.

```vim
nnoremap <space>tw viw:Translate ZH<CR>
```
