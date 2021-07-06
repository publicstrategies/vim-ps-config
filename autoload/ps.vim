""
" Needs to be set outside function or weird things happen due to <sfile>.
let s:base_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

""
" Sets up a new PS project. If reload = 1, will reload the plugin.
function! ps#NewProject(reload) abort
  call ps#CreateDirectory(ps#database#GetSQLDir())
  call ps#CreateDirectory(ps#notes#GetNotesDir())
  call ps#CreateDirectory(ps#database#GetDBDiagramDir())
  call ps#CreateDirectory(ps#rest#GetRestDir())
  if getfsize('.vimrc') > 0
    call ps#Warn("'.vimrc' already exists and not empty.")
    return
  endif
  call ps#Vimrc(a:reload)
endfunction

""
" Creates a directory.
function! ps#CreateDirectory(directory) abort
  if isdirectory(a:directory) | return 0 | endif
  call mkdir(a:directory, 'p')
  return 1
endfunction

""
" Opens/creates a file.
function! ps#OpenFile(dir, resource, ext) abort
  if !isdirectory(a:dir) | call ps#CreateDirectory(a:dir) | endif
  let l:file = a:dir . a:resource
  if l:file !~#  '\.' . a:ext . '$' | let l:file = l:file . '.' . a:ext | endif
  execute 'edit' l:file
endfunction

""
" Completions for files.
function! ps#FileCompletion(dir, ext) abort
  if !isdirectory(a:dir) | call ps#CreateDirectory(a:dir) | endif
  let l:list = glob(a:dir . '**/*.' . a:ext, 0, 1)
  return join(map(l:list, "substitute(v:val, a:dir, '', '')"), "\n")
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
        \    "\" Change the sql file directory. The default is '" . ps#database#GetSQLDir() . "'",
        \    "\" let g:db_sql_directory = '"  . ps#database#GetSQLDir() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the dbml file directory. The default is '" . ps#database#GetDBDiagramDir() . "'",
        \    "\" let g:db_diagram_directory = '"  . ps#database#GetDBDiagramDir() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the notes file directory. The default is '" . ps#notes#GetNotesDir() . "'",
        \    "\" let g:db_notes_directory = '"  . ps#notes#GetNotesDir() . "'",
        \    "",
        \    "\"\"",
        \    "\" Change the rest file directory. The default is '" . ps#rest#GetRestDir() . "'",
        \    "\" let g:db_rest_directory = '"  . ps#rest#GetRestDir() . "'",
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
function! ps#ReloadPlugin() abort
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
" True if dadbad isn't disabled.
function! ps#CanUseDadbod() abort
  return get(g:, 'ps_config_use_dadbod', 1)
endfunction

""
" True if consistency isn't disabled.
function! ps#CanUseConsistency() abort
  return get(g:, 'ps_config_use_consistency', 1)
endfunction

""
" True if framework commands aren't disabled.
function! ps#CanUseFrameworkCommands() abort
  return get(g:, 'ps_config_use_framework_commands', 1)
endfunction

""
" True if notes isn't disabled.
function! ps#CanUseNotes() abort
  return get(g:, 'ps_config_use_notes', 1)
endfunction

""
" True if rest isn't disabled.
function! ps#CanUseRest() abort
  return get(g:, 'ps_config_use_rest', 1)
endfunction
