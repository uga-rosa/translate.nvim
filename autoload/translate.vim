let s:modes = ['command', 'parse', 'output', 'source']

function! translate#complete(arglead, cmdline, cursorpos) abort
    if a:arglead =~# '^-.*=' || a:arglead !~# '^-'
        let l:modes = matchlist(a:arglead, '^-\(.*\)=')
        if len(l:modes) == 0
            let l:mode = 'target'
        else
            let l:mode = l:modes[1]
        endif
        let l:list = luaeval('require("translate.config").get_complete_list(_A[1], _A[2])', [l:mode, a:cmdline])
        return l:list
    elseif a:arglead =~# '^-'
        return s:modes
    endif
endfunction
