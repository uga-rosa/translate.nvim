let s:modes = ['parse_before', 'command', 'parse_after', 'output', 'source']

function! translate#complete(arglead, cmdline, cursorpos) abort
    if  a:arglead !~# '^-'
		let l:mode = 'target'
	elseif a:arglead =~# '^-.*='
        let l:mode = matchlist(a:arglead, '^-\(.*\)=')[1]
    elseif a:arglead =~# '^-'
        return s:modes
    endif
	return luaeval('require("translate.config").get_complete_list(_A[1], _A[2])', [l:mode, a:cmdline])
endfunction
