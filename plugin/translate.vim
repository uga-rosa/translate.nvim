if exists("g:loaded_translate_nvim")
    finish
endif
let g:loaded_translate_nvim = v:true

command! -range=0 -nargs=+ -complete=customlist,translate#complete
            \ Translate lua require("translate").translate(<count>, <f-args>)
