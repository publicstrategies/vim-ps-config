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
  call database#CreateSQLDir(0)
  call notes#CreateNotesDir(0)

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
        \    "\" .vimrc contents generated by vim-ps-config.",
        \    "\" " . strftime('%c'),
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
        \    "\" Change the sql file directory. The default is '" . database#GetSQLDirectory() . "'",
        \    "\" let g:db_sql_directory = '"  . database#GetSQLDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the dbml file directory. The default is '" . database#GetDBDiagramDirectory() . "'",
        \    "\" let g:db_diagram_directory = '"  . database#GetDBDiagramDirectory() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the notes file directory. The default is '" . notes#GetNotesDirectory() . "'",
        \    "\" let g:db_notes_directory = '"  . notes#GetNotesDirectory() . "'",
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
  if exists('g:is_ps_project') && g:is_ps_project | return 1 | endif

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
" True if is_ps_project is true, and dadbad isn't disabled.
function! ps#CanUseDadbod() abort
  return s:VarNotDisabled('g:ps_config_use_dadbod')
endfunction

""
" True if is_ps_project is true, and consistency isn't disabled.
function! ps#CanUseConsistency() abort
  return s:VarNotDisabled('g:ps_config_use_consistency')
endfunction

""
" True if is_ps_project is true, and framework commands aren't disabled.
function! ps#CanUseFrameworkCommands() abort
  return s:VarNotDisabled('g:ps_config_use_framework_commands')
endfunction

""
" True if is_ps_project is true, and notes isn't disabled.
function! ps#CanUseNotes() abort
  return s:VarNotDisabled('g:ps_config_use_notes')
endfunction

""
" True if is_ps_project is true, and curl isn't disabled.
function! ps#CanUseCurl() abort
  return s:VarNotDisabled('g:ps_config_use_curl')
endfunction

""
" Call curl commands.
function! ps#Curl() abort
  let l:command = ps#GetSelection()
  if split(l:command)[0] != 'curl'
    let l:command = 'curl ' . l:command
  endif
  execute 'botright' 'terminal' l:command
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
" True if var doesn't exist or exists and isn't false.
function! s:VarNotDisabled(var) abort
  return ps#IsPsProject() && (!exists(a:var) || eval(a:var))
endfunction

""
" Try to intelligently determine where database directory should be located.
" TODO is this the best way to handle this?
function! s:GetDatabaseDir()
  if isdirectory('db') | return 'db/sql' | endif
  if isdirectory('database') | return 'database/sql' | endif
  return 'sql'
endfunction
