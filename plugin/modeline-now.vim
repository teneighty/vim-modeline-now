" gen-modeline.vim - Add/Replace a modeline 
" Maintainer:   Tim Horton <tmhorton@gmail.com>
" Version:      0.1

let g:modeline_options = []

" {{{ Plugin
function! s:ctuple()
  return map(split(substitute(
        \&commentstring, '%s', ' %s ', ''), '%s'), "substitute(v:val, '\\s', '', 'g')")
endfunction

function! s:escapedtuple()
  return map(s:ctuple(), "escape(v:val, '*')")
endfunction

function! s:isopt(opt)
  if eval('type(&' . a:opt . ')') != 0
    return 0
  endif
  let prev = eval('&' . a:opt)
  try
    " test if we can change value
    exe 'set ' . a:opt . '=1'
    " restore value
    exe 'set ' . a:opt . '=' . prev
  catch /.*/
    " do nothing
    return 1
  endtry
  return 0
endfunction

function! s:build()
  let [l, r] = s:ctuple()
  let ml = l . ' vim:set'
  for a in g:modeline_options
    if s:isopt(a)
      let ml .= ' ' . a
    else 
      let ml .= ' ' . a . '=' . eval('&' . a)
    endif
  endfor
  return ml . ': ' . r
endfunction

function! s:replace()
  let ml = s:build()
  let pos = getpos('.')
  let [l,r] = s:escapedtuple()
  let num = search(l . '.*vim:set.*' . r)
  if num > 0
    call setline(num, ml)
  else
    exe "norm Go\<CR>\<Esc>"
    call setline(line('.'), ml)
  endif
  call setpos('.', pos)
endfunction

function! s:setopts(...)
  let g:modeline_options = []
  for a in a:000
    if exists('&' . a)
      call add(g:modeline_options, a)
    endif
  endfor
endfunction
" }}}

command! -nargs=+ ModelineOpts :call s:setopts(<f-args>)

ModelineOpts ft sw ts et

nnoremap <silent> <Plug>Modeline :<C-U>call <SID>replace()<CR>

if !hasmapto('<Plug>Modeline') || maparg('<C-M><C-L>', 'n') ==# ''
  nmap <C-M><C-L> <Plug>Modeline
endif

" vim:set ft=vim sw=2 ts=2 et fdm=marker: 
