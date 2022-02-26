
" Z && TZ {{{
" ============================================================================
" TODO there are two level when zf reback the cwd when the zf path ,
" from cwd to the path
let s:savedCwd = ""
function s:stashCwd()
  let s:savedCwd = getcwd()

endfunction
function s:getzlua() 
  let l:list = systemlist("cat ~/.zlua")
  let l:home = $HOME
  for i in range(len(l:list))
    let l:list[i] = split(l:list[i],"|")[0]
    let l:list[i] = substitute(l:list[i],l:home,"~","g")
  endfor
  let list = l:list
  return list
endfunction

function! ZComp(ArgLead, CmdLine, CursorPos)
  let l:list = systemlist("cat ~/.zlua")
  let l:home = $HOME
  for i in range(len(l:list))
    let l:list[i] = split(l:list[i],"|")[0]
    let l:list[i] = substitute(l:list[i],l:home,"~","g")
  endfor
  return filter(l:list,'v:val =~ a:ArgLead')
  " return filter(systemlist("cat ~/.zlua | awk -F \"|\" '{print $1;}'"), 'v:val =~ a:ArgLead')
endfunction

function s:dozFunc(mode,path)
  if(a:mode == "tab")
    execute "tabnew"
    execute "tcd ".a:path
  elseif(a:mode == "win")
    execute "vertical botright 80new"
    execute "lcd ".a:path
  else
    execute "tcd ".a:path
  endif
  echom "".getcwd()
endfunction

function! ZFunc(mode,...)
  " TODO get all the path in the current path
  let l:list = []
  let l:index = []
  let l:params = copy(a:000)
  if ( a:mode == "fwd" )
    if (s:savedCwd == "")
      call s:stashCwd()
    endi
    let l:list = systemlist("fd . ".s:savedCwd." -t directory")
    if(len(l:params) == 0)
      call s:dozFunc(a:mode,s:savedCwd)
      return
    endif
    let l:params = insert(l:params,s:savedCwd)
  else
    let l:list = s:getzlua()
    let s:savedCwd = ""
  endif
  if(len(l:params) == 1)
    if(match(l:params[0],'[\x7E]')>= 0)
      call s:dozFunc(a:mode,l:params[0])
      return
    endif
  endif
  for i in range(0,len(l:list)-1) 
    let flag = 0
    let path = l:list[i]
    for j in range(0,len(l:params)-1)
      let val = l:params[j]
      if(match(path,val) >= 0)
        let path = path[match(path,val)+len(val):len(path)-1]
        let flag = 1
      else
        let flag = 0
        break
      endif
    endfor
    if(flag)
      call add(l:index,i)
    endif
  endfor
  if(len(l:index)>0)
    call s:dozFunc(a:mode,l:list[l:index[0]])
  else
    echom "no match path"
  endif
endfunction

command! -nargs=* -complete=customlist,ZComp Z call ZFunc(<f-args>)
nnoremap <leader>zt :<C-U><C-R>=printf("Z tab ")<CR>
nnoremap <leader>zl :<C-U><C-R>=printf("Z win ")<CR>
nnoremap <leader>zz :<C-U><C-R>=printf("Z self ")<CR>
nnoremap <leader>zf :<C-U><C-R>=printf("Z fwd ")<CR>
"}}}
" ============================================================================
