# translate.nvim

![demo](https://user-images.githubusercontent.com/82267684/157377303-484f496e-2eed-482d-bb89-cabd011cf978.gif)


# Features

- You can use any command you like for translation.
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

- neovim 0.5.0+

If you use [translate-shell](https://github.com/soimort/translate-shell), you need to install `trans` command.

If you use [DeepL API Pro/Free](https://www.deepl.com/en/docs-api/), you need the authorization key for DeepL API Pro/Free.
In addition, you need [curl](https://curl.se/) to send the request.


# Quick start

## Install

With any plugin manager you like (e.g. [vim-plug](https://github.com/junegunn/vim-plug), [packer.nvim](https://github.com/wbthomason/packer.nvim), [dein.vim](https://github.com/Shougo/dein.vim))

## Setup

This plugin has default settings, so there is no need to call setup if you want to use it as is.

This is my setting.

```vim
let g:deepl_api_auth_key = 'MY_AUTH_KEY'
lua <<EOL
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
EOL
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
    			The functions to format texts of selection.
    			You can use a comma-separated string.
    			If omitted, |translate-nvim-option-default-parse-before|.
    		- '-command='
    			The extermal command to use translation. If omitted,
    			|translate-nvim-option-default-command| is used.
    		- '-parse_after='
    			The functions to format the result of extermal command.
    			You can use a comma-separated string.
    			If omitted, |translate-nvim-option-default-parse-after|.
    		- '-output='
    			The function to pass the translation result.
    			If omitted, |translate-nvim-option-default-output|.
    
    
    	If mapping |:Translate|, Do NOT use |<Cmd>|. I use [range] to check
    	whether this command is called from normal mode or visual mode. Please
    	map them as follows.
    

    	nnoremap mei :<C-u>Translate EN -parse_after=oneline -output=insert<CR>
    	xnoremap mer :Translate EN -parse_after=head -output=replace<CR>


</div></details>

## Keymap

As noted in the help, do not use `<Cmd>` when mapping the :Translate command.

This is my setting.

```vim
nnoremap <silent> mjf :<C-u>Translate JA -parse_after=remove_newline,window -output=floating<CR>
xnoremap <silent> mjf :Translate JA -parse_after=remove_newline,window -output=floating<CR>
nnoremap <silent> mjs :<C-u>Translate JA -parse_after=remove_newline,oneline -output=split<CR>
xnoremap <silent> mjs :Translate JA -parse_after=remove_newline,oneline -output=split<CR>
nnoremap <silent> mji :<C-u>Translate JA -parse_after=remove_newline,head -output=insert<CR>
xnoremap <silent> mji :Translate JA -parse_after=remove_newline,head -output=insert<CR>
nnoremap <silent> mjr :<C-u>Translate JA -parse_after=remove_newline,head -output=replace<CR>
xnoremap <silent> mjr :Translate JA -parse_after=remove_newline,head -output=replace<CR>

nnoremap <silent> mef :<C-u>Translate EN -parse_after=remove_newline,window -output=floating<CR>
xnoremap <silent> mef :Translate EN -parse_after=remove_newline,window -output=floating<CR>
nnoremap <silent> mes :<C-u>Translate EN -parse_after=remove_newline,oneline -output=split<CR>
xnoremap <silent> mes :Translate EN -parse_after=remove_newline,oneline -output=split<CR>
nnoremap <silent> mei :<C-u>Translate EN -parse_after=remove_newline,head -output=insert<CR>
xnoremap <silent> mei :Translate EN -parse_after=remove_newline,head -output=insert<CR>
nnoremap <silent> mer :<C-u>Translate EN -parse_after=remove_newline,head -output=replace<CR>
xnoremap <silent> mer :Translate EN -parse_after=remove_newline,head -output=replace<CR>
```
