""
" Map adapters to query snippets.
let s:adapter_mappings = {
      \   'postgres': {
      \     'show_tables': '\dt',
      \     'describe': '\d'
      \   },
      \   'mysql': {
      \     'show_tables': 'SHOW TABLES',
      \     'describe': 'DESCRIBE'
      \   }
      \ }

""
" List which database the b:db or g:db url points to. If ! is used, Also show
" the actual URL.
function! ps#database#DBList(show_url) abort
  if !s:ValidateVariables() | return | endif
  let l:db = ps#database#GetURL()
  for [l:key, l:value] in g:db_list
    if l:value ==# l:db
      let l:string = ps#database#GetDBVar() . ' is set to ' . l:key
      if a:show_url | let l:string .= ': ' . l:db | endif
      if match(l:key, 'production') >= 0
        call ps#Warn(l:string)
      else
        echo l:string
      endif
      return
    endif
  endfor
  call ps#Warn('No database set!')
endfunction

""
" Function that switches the database URL.
" NOTE that this only changes it for the current BUFFER, not globally!
function! ps#database#DBSwitch(force, ...) abort
  if !s:ValidateVariables() | return | endif
  let l:database = a:0 == 1 ? a:1 : g:db_default_database
  for [l:key, l:value] in g:db_list
    if l:key ==# l:database
      let l:string = 'Switching to ' . l:database . ' database: ' . l:value
      if match(l:key, 'production') >= 0
        if !a:force && s:ConfirmProduction() != 1 | return | endif
        if !get(g:, 'db_switch_silently', 0) | call ps#Warn(l:string) | endif
      else
        if !get(g:, 'db_switch_silently', 0) | echo l:string | endif
      endif
      let b:db = l:value
      return
    endif
  endfor
  call ps#Warn('No DB defined for ' . l:database)
endfunction

""
" Finds the database by 'key' in g:db list. If not found, returns the defualt.
function! ps#database#FindDBByKey(key, use_dev_suffix, default) abort
  if !s:ValidateVariables() | return | endif
  for [l:key, l:value] in g:db_list
    if l:key ==# a:key ||
          \ (a:use_dev_suffix && l:key ==# a:key . '_' . g:db_default_database)
      return l:value
    endif
  endfor
  return a:default
endfunction

""
" Generates SQL based argument passed, or off current file name if no args.
" If `place_above_cursor` is 1, will insert text above corser position.
function! ps#database#GenerateSQL(place_above_cursor, ...) abort
  if !s:ValidateVariables() | return | endif
  let l:table = a:0 ? a:1 : expand('%:t:r')
  let l:adapter = ps#database#GetAdapter()
  call append(a:place_above_cursor ? line('.') - 1 : line('.'), [
        \   '-- List all tables in the database.',
        \   s:adapter_mappings[l:adapter].show_tables . ';',
        \   '',
        \   "-- Describe '" . l:table . "' table's attributes.",
        \   s:adapter_mappings[l:adapter].describe . ' ' . l:table . ';',
        \   '',
        \   "-- Count records in '" . l:table . "'.",
        \   'SELECT count(*) FROM ' . l:table . ';',
        \   '',
        \   "-- List all records from the '" . l:table . "' table.",
        \   'SELECT * FROM ' . l:table . ';',
        \ ])
  let &modified = 1
endfunction

""
" Generates DBDiagram based argument passed, or off current file name if no args.
" If `place_above_cursor` is 1, will insert text above corser position.
function! ps#database#GenerateDBDiagram(place_above_cursor, ...) abort
  let l:table = a:0 ? a:1 : expand('%:t:r')
  call append(a:place_above_cursor ? line('.') - 1 : line('.'), [
        \   '// View diagrams on https://dbdiagram.io',
        \   '',
        \   'Table ' . l:table . ' as ' . join(map(split(l:table, '_'), 'v:val[0]'), '') . ' {',
        \   '  id int [pk, increment]',
        \   '',
        \   '  created_at timestamp',
        \   '  updated_at timestamp',
        \   '}',
        \ ])
  let &modified = 1
endfunction

""
" Returns the adapter from URL.
function! ps#database#GetAdapter() abort
  return split(ps#database#GetURL(), ':')[0]
endfunction

""
" Returns the current value of b:db, or g:db.
function! ps#database#GetURL() abort
  for l:var in ['b:db', 'g:db']
    if exists(l:var) | return eval(l:var) | endif
  endfor
endfunction

""
" Returns the DBDiagram directory.
function! ps#database#GetDBDiagramDir() abort
  return resolve(expand(s:GetDir('g:db_diagram_directory', 'diagrams'))) . '/'
endfunction

""
" TODO Rename these single line functions as `s:` variables. Just make sure we
" don't need them outside this file.
" Returns the sql directory.
function! ps#database#GetSQLDir() abort
  return resolve(expand(s:GetDir('g:db_diagram_directory', 'sql'))) . '/'
endfunction

""
" Returns the current b:db, or g:db.
function! ps#database#GetDBVar() abort
  for l:var in ['b:db', 'g:db']
    if exists(l:var) | return l:var | endif
  endfor
endfunction

""
" Completions for DBDiagram Files.
function! ps#database#DBDiagramCompletion(arg_lead, cmd_line, cursor_pos) abort
  return ps#FileCompletion(ps#database#GetDBDiagramDir(), 'dbml')
endfunction

""
" Completions for SQL Files.
function! ps#database#SQLFileCompletion(arg_lead, cmd_line, cursor_pos) abort
  return ps#FileCompletion(ps#database#GetSQLDir(), 'sql')
endfunction

""
" Completion options for db handles, which are the keys to g:db_list.
function! ps#database#ListCompletions(arg_lead, cmd_line, cursor_pos) abort
  if !s:ValidateVariables() | return | endif
  let l:copy = deepcopy(g:db_list)
  return join(map(l:copy, 'v:val[0]'), "\n")
endfunction

function! ps#database#InitializeDBDiagram() abort
  let s:db_diagram_directory = ps#database#GetDBDiagramDir()
  let s:current_dir = fnamemodify(resolve(expand('%:p')), ':h') . '/'
  if match(s:current_dir, s:db_diagram_directory) >= 0
    if !isdirectory(s:current_dir) | call mkdir(s:current_dir, 'p') | endif
    if getfsize(@%) <= 0 | call ps#database#GenerateDBDiagram(1) | endif
  endif
endfunction

function! ps#database#InitializeSQL() abort
  let s:db_sql_directory = ps#database#GetSQLDir()
  let s:current_dir = fnamemodify(resolve(expand('%:p')), ':h') . '/'
  if match(s:current_dir, s:db_sql_directory) >= 0
    if !exists('g:db_list')
      call ps#Warn("g:db_list not set. Can't set URL.")
    else
      if !isdirectory(s:current_dir) | call mkdir(s:current_dir, 'p') | endif
      let b:db = ps#database#FindDBByKey(split(s:current_dir, '/')[-1], 1, g:db)
      if getfsize(@%) <= 0 | call ps#database#GenerateSQL(1) | endif
    endif
  endif
endfunction

"============="
" PRIVATE API "
"============="

""
" Makes sure g:db_list exists.
function! s:ValidateVariables() abort
  if exists('g:db_list') && !empty(g:db_list) | return 1 | endif
  call ps#Warn('g:db_list is not set! Please set in `.vimrc` file!')
  return 0
endfunction

function! s:ConfirmProduction() abort
  if !get(g:, 'db_switch_confirm_production', 1) | return 1 | endif
  return confirm('PRODUCTION, ARE YOU SURE?', "&Yes\n&No", 2, 'Question')
endfunction

function! s:GetDir(variable, subdir) abort
  if exists(a:variable)
    let l:dir = eval(a:variable)
  elseif isdirectory('db')
    return 'db/' . a:subdir
  elseif isdirectory('database')
    return 'database/' . a:subdir
  endif
  return a:subdir
endfunction
