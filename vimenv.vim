
command! -nargs=? Smake call SampMake(<q-args>)
func! SampMake(parm)
	update
	botright new
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile wrap
	silent execute "read !compile.bat" a:parm
	silent! %s/\r//g
	setlocal nomodifiable
endfunc
