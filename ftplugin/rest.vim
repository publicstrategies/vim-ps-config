if !ps#CanUseRest() | finish | endif

let g:vrc_curl_opts = { '-i': '', '-s': '' }

let s:rest_file_directory = rest#GetRestDirectory()
let s:dir_name = fnamemodify(resolve(expand('%:p')), ':h') . '/'

if match(s:dir_name, s:rest_file_directory) >= 0
  if !exists('$PS_TOKEN') && get(g:, 'ps_rest_auto_sign_in', 1)
    call rest#SignIn(0)
  endif
  if !isdirectory(s:dir_name) | call mkdir(s:dir_name, 'p') | endif
  if getfsize(@%) <= 0 | call rest#GenerateRest(1) | endif
endif
