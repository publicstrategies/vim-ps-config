""
" Needs to be set outside function or weird things happen due to <sfile>.
let s:base_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

let s:mode_map = {
      \ 'n'  : 'Normal',
      \ 'no' : 'N·Operator Pending',
      \ 'v'  : 'Visual',
      \ 'V'  : 'V·Line',
      \ '' : 'V·Block',
      \ 's'  : 'Select',
      \ 'S'  : 'S·Line',
      \ '' : 'S·Block',
      \ 'i'  : 'Insert',
      \ 'R'  : 'Replace',
      \ 'Rv' : 'V·Replace',
      \ 'c'  : 'Command',
      \ 'cv' : 'Vim Ex',
      \ 'ce' : 'Ex',
      \ 'r'  : 'Prompt',
      \ 'rm' : 'More',
      \ 'r?' : 'Confirm',
      \ '!'  : 'Shell',
      \}

""
" Sets up a new PS project. If reload = 1, will reload the plugin.
function! ps#NewProject(reload) abort
  call ps#database#CreateSQLDir(0)
  call ps#notes#CreateNotesDir(0)
  call ps#database#CreateDBDiagramDir(0)
  call ps#rest#CreateRestDir(0)

  if getfsize('.vimrc') > 0
    call ps#Warn("'.vimrc' already exists and not empty.")
    return
  endif

  call ps#Vimrc(a:reload)
endfunction

""
" Generate default .vimrc file contents. If reload = 1, will reload the plugin.
function! ps#Vimrc(reload) abort
  execute 'edit' '.vimrc'

  call append(0, [
        \    "\" NOTE For more help, update your helptags and read the help.",
        \    "\"   :helptags ALL",
        \    "\"   :help ps_config",
        \    "",
        \    "\"\"",
        \    "\" Necessary for the vim-ps-plugin to run. Comment to disable plugin.",
        \    "let g:is_ps_project = 1",
        \    "",
        \    "\"\"",
        \    "\" Change the list of consistency settings. The default is what's in the example.",
        \    "\" let g:ps_consistency_settings_list = [",
        \    "\"      \\\   'nocompatible',",
        \    "\"      \\\   'expandtab',",
        \    "\"      \\\ ]",
        \    "",
        \    "\"\"",
        \    "\" Change the default database. The default is 'development'.",
        \    "\" let g:db_default_database = 'development'",
        \    "",
        \    "\"\"",
        \    "\" Change the sql file directory. The default is '" . ps#database#GetSQLDirectory() . "'",
        \    "\" let g:db_sql_directory = '"  . ps#database#GetSQLDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the dbml file directory. The default is '" . ps#database#GetDBDiagramDirectory() . "'",
        \    "\" let g:db_diagram_directory = '"  . ps#database#GetDBDiagramDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the notes file directory. The default is '" . ps#notes#GetNotesDirectory() . "'",
        \    "\" let g:db_notes_directory = '"  . ps#notes#GetNotesDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the rest file directory. The default is '" . ps#rest#GetRestDirectory() . "'",
        \    "\" let g:db_notes_directory = '"  . ps#rest#GetRestDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the list of available database URLs. There is no default.",
        \    "\" let g:db_list = [",
        \    "\"       \\\   ['development', 'adapter://user:password@host:port/database'],",
        \    "\"       \\\ ]",
        \ ])

  if !a:reload
    let &modified = 1
    return
  endif

  execute 'write'
  call ps#ReloadPlugin()
endfunction

""
" Sources .vimrc if it exists, and re-sources the main plugin file.
" If source_vimrc = 1, re-sources .vimrc if it exists.
function! ps#ReloadPlugin()
  if filereadable('./.vimrc') | source ./.vimrc | endif
  let g:ps_loaded_config = 0
  execute 'source' s:base_dir . '/plugin/ps_config.vim'
endfunction

""
" Print an error message (red).
function! ps#Warn(message) abort
  echohl ErrorMsg | echomsg 'PS Plugin: ' . a:message | echohl None
endfunction

""
" True if g:is_ps_project is true
function! ps#IsPsProject() abort
  if get(g:, 'is_ps_project') | return 1 | endif

  if exists('g:is_psi_project')
    if !exists('g:ps_did_deprecation_warning')
      call ps#Warn('g:is_psi_project is deprecated in favor of g:is_ps_project.')
      let g:ps_did_deprecation_warning = 1
    endif
    if g:is_psi_project | return 1 | endif
  endif

  return 0
endfunction

""
" Pulls master. If ! is provided, reloads the plugin.
function! ps#UpdatePlugin() abort
  let l:output = system('cd ' . shellescape(s:base_dir) .
        \ ' && git pull origin master')
  echo l:output
  echo 'Plugin updated! Please restart vim.'
endfunction

""
" True dadbad isn't disabled.
function! ps#CanUseDadbod() abort
  return get(g:, 'ps_config_use_dadbod', 1)
endfunction

""
" True consistency isn't disabled.
function! ps#CanUseConsistency() abort
  return get(g:, 'ps_config_use_consistency', 1)
endfunction

""
" True framework commands aren't disabled.
function! ps#CanUseFrameworkCommands() abort
  return get(g:, 'ps_config_use_framework_commands', 1)
endfunction

""
" True notes isn't disabled.
function! ps#CanUseNotes() abort
  return get(g:, 'ps_config_use_notes', 1)
endfunction

""
" True rest isn't disabled.
function! ps#CanUseRest() abort
  return get(g:, 'ps_config_use_rest', 1)
endfunction

""
" Gets visual selection. Credit:
" https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! ps#GetSelection()
  if mode() =~# '\v(n|no)'
    return getline('.')
  elseif mode() =~# '\v(v|V)' || s:mode_map[mode()] ==# 'V·Block'
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0 | return '' | endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
  endif
endfunction

"============="
" Private API "
"============="

""
" Try to intelligently determine where database directory should be located.
function! s:GetDatabaseDir()
  if isdirectory('db') | return 'db/sql' | endif
  if isdirectory('database') | return 'database/sql' | endif
  return 'sql'
endfunction
