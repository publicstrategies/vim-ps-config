""
" Sign into the website and set $PS_TOKEN to the jwt.
function! rest#SignIn(verbose, ...) abort
  if a:0
    let l:token = a:1
  else
    for l:var in ['ps_rest_curl_command', 'ps_rest_token_regex']
      if !exists('g:' . l:var)
        call ps#Warn('g:' . l:var . " not set. Can't sign in.")
        return
      endif
    endfor
    let l:token = matchstr(system(g:ps_rest_curl_command), g:ps_rest_token_regex)
    if empty(l:token)
      call ps#Warn('Token not found in cURL output.')
      return
    endif
  endif

  if a:verbose | echo 'Token set: ' . l:token | endif
  let $PS_TOKEN = l:token
endfunction

""
" Returns the rest directory.
function! rest#GetRestDirectory()
  let l:dir = get(g:, 'ps_rest_directory', 'test/support/api/rest')

  return resolve(expand(l:dir)) . '/'
endfunction

""
" Opens/creates a rest file.
""
" Opens/creates a sql file.
function! rest#File(controller) abort
  let l:dir = rest#GetRestDirectory()
  if !isdirectory(l:dir) | call rest#CreateRestDir() | endif
  let l:file = l:dir . a:controller

  if l:file !~#  '\.rest$' | let l:file = l:file . '.rest' | endif

  execute 'edit' l:file
endfunction

""
" Creates the rest directory.
function! rest#CreateRestDir(fail_silently) abort
  let l:dir = rest#GetRestDirectory()

  if isdirectory(l:dir)
    if !a:fail_silently
      call ps#Warn("Directory '" . l:dir . "' already exists.")
    endif
    return 0
  endif

  call mkdir(l:dir, 'p')
  return 1
endfunction

""
" Completions for rest files.
function! rest#FileCompletion(arg_lead, cmd_line, cursor_pos) abort
  let l:dir = rest#GetRestDirectory()
  if !isdirectory(l:dir) | call rest#CreateRestDir(1) | endif
  let l:olddir = chdir(l:dir)
  let l:list = glob('**/*.rest', 0, 1)
  call chdir(l:olddir)
  return join(l:list, "\n")
endfunction

""
" Generates Rest file based argument passed, or off current file name if no args.
" If `place_above_cursor` is 1, will insert text above corser position.
function! rest#GenerateRest(place_above_cursor, ...) abort
  let l:controller = a:0 ? a:1 : expand('%:t:r')
  let l:cursor_pos = line('.')

  if a:place_above_cursor | let l:cursor_pos -= 1 | endif

  call append(l:cursor_pos, ["bearer = $PS_TOKEN", ""] +
        \   get(g:, 'ps_rest_curl_opts', ['# Add curl options here']) +
        \   ["", "Accept: application/json",
        \   "Content-Type: application/json",
        \   "Authorization: Bearer :bearer"] +
        \   get(g:, 'ps_rest_headers', ['# Add headers here']) +
        \   ["", "--", "",
        \   "http://localhost:3000",
        \   "GET /api/" . l:controller
        \ ])

  let &modified = 1
endfunction
