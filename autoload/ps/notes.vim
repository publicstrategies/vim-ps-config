""
" Returns the notes directory.
function! ps#notes#GetNotesDir() abort
  let l:dir = get(g:, 'ps_notes_directory', 'docs')
  return resolve(expand(l:dir)) . '/'
endfunction

""
" Opens/creates a notes file.
function! ps#notes#File(...) abort
  let l:dir = ps#notes#GetNotesDir()
  if !isdirectory(l:dir) | call ps#CreateDirectory(l:dir) | endif
  let l:file = l:dir . substitute(tolower(join(a:000, '_')), "_*\/_*", "/", 'g')
  if l:file !~#  '\.md$' | let l:file = l:file . '.md' | endif
  let l:title = substitute(fnamemodify(l:file, ':t:r'), '_', ' ', 'g')
  let l:title = substitute(l:title, '\<.', '\u&', 'g')
  let l:basedir = fnamemodify(l:file, ':h')
  if !isdirectory(l:basedir) | call mkdir(l:basedir, 'p') | endif
  execute 'edit' l:file
  if getfsize(l:file) > 0 | return | endif
  call append(0, ["# " . l:title])
endfunction

""
" Completions for notes files.
function! ps#notes#NoteFileCompletion(arg_lead, cmd_line, cursor_pos) abort
  return ps#FileCompletion(ps#notes#GetNotesDir(), 'md')
endfunction
