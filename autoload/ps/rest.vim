""
" Sign into the website and set $PS_TOKEN to the jwt.
function! ps#rest#SignIn(verbose, ...) abort
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
function! ps#rest#GetRestDir() abort
  let l:dir = get(g:, 'ps_rest_directory', 'test/support/api/rest')
  return resolve(expand(l:dir)) . '/'
endfunction

""
" Completions for rest files.
function! ps#rest#FileCompletion(arg_lead, cmd_line, cursor_pos) abort
  return ps#FileCompletion(ps#rest#GetRestDir(), 'rest')
endfunction

""
" Generates Rest file based argument passed, or off current file name if no args.
" If `place_above_cursor` is 1, will insert text above corser position.
function! ps#rest#GenerateRest(place_above_cursor, ...) abort
  let l:controller = a:0 ? a:1 : expand('%:t:r')
  call append(a:place_above_cursor ? line('.') - 1 : line('.'),
        \   ["bearer = $PS_TOKEN", ""] +
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

function! ps#rest#InitializeRest() abort
  let g:vrc_curl_opts = { '-i': '', '-s': '' }
  let s:rest_file_directory = ps#rest#GetRestDir()
  let s:dir_name = fnamemodify(resolve(expand('%:p')), ':h') . '/'
  if match(s:dir_name, s:rest_file_directory) >= 0
    if !exists('$PS_TOKEN') && get(g:, 'ps_rest_auto_sign_in', 1)
      call ps#rest#SignIn(0)
    endif
    if !isdirectory(s:dir_name) | call mkdir(s:dir_name, 'p') | endif
    if getfsize(@%) <= 0 | call ps#rest#GenerateRest(1) | endif
  endif
endfunction
