if exists("g:loaded_translate_nvim")
    finish
endif
let g:loaded_translate_nvim = v:true

command! -range=0 -nargs=+ -complete=customlist,translate#complete
            \ Translate lua require("translate").translate(<count>, <f-args>)

let b:translate_old_mode = 'n'

augroup _translate_mode_save
    au!
    au ModeChanged *:n let b:translate_old_mode = v:event.old_mode
augroup END
