""
" Map adapters to query snippets.
let s:ShowTablesDictionary = {
      \   'postgres': '\dt',
      \   'mysql':    'SHOW TABLES'
      \ }
let s:DescribeTablesDictionary = {
      \   'postgres': '\d',
      \   'mysql':    'DESCRIBE',
      \ }

""
" List which database the b:db or g:db url points to. If ! is used, Also show
" the actual URL.
function! ps#database#DBList(show_url) abort
  if !s:validate() | return | endif

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
  if !s:validate() | return | endif

  let l:database = a:0 == 1 ? a:1 : g:db_default_database

  for [l:key, l:value] in g:db_list
    if l:key ==# l:database
      let l:string = 'Switching to ' . l:database . ' database: ' . l:value

      if match(l:key, 'production') >= 0
        if !a:force && s:ConfirmProduction() != 1
          return
        endif
        if (!exists('g:db_switch_silently') || !g:db_switch_silently)
          call ps#Warn(l:string)
        endif
      else
        if (!exists('g:db_switch_silently') || !g:db_switch_silently)
          echo l:string
        endif
      endif

      let b:db = l:value
      return
    endif
  endfor

  call ps#Warn('No DB defined for ' . l:database)
endfunction

""
" Finds the database by 'key' in g:db list. If not found, returns the defualt.
" HACK? I was getting tired and couldn't think of an easier way to get the
"       'key' from the 2-D list.
function! ps#database#FindDBByKey(key, use_dev_suffix, default) abort
  if !s:validate() | return | endif

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
  if !s:validate() | return | endif

  let l:table = a:0 ? a:1 : expand('%:t:r')
  let l:adapter = ps#database#GetAdapter()
  let l:cursor_pos = line('.')

  if a:place_above_cursor | let l:cursor_pos -= 1 | endif

  call append(l:cursor_pos, [
        \   '-- List all tables in the database.',
        \   s:ShowTablesDictionary[l:adapter] . ';',
        \   '',
        \   "-- Describe '" . l:table . "' table's attributes.",
        \   s:DescribeTablesDictionary[l:adapter] . ' ' . l:table . ';',
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
  let l:cursor_pos = line('.')

  if a:place_above_cursor | let l:cursor_pos -= 1 | endif

  call append(l:cursor_pos, [
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
" Opens/creates a sql file.
function! ps#database#File(table) abort
  let l:dir = ps#database#GetSQLDirectory()
  if !isdirectory(l:dir) | call ps#database#CreateSQLDirectory() | endif
  let l:file = l:dir . a:table

  if l:file !~#  '\.sql$' | let l:file = l:file . '.sql' | endif

  execute 'edit' l:file
endfunction

""
" Opens/creates a dbdiagram file.
function! ps#database#DBDiagram(table) abort
  let l:dir = ps#database#GetDBDiagramDirectory()
  if !isdirectory(l:dir) | call ps#database#CreateDBDiagramDirectory() | endif
  let l:file = l:dir . a:table

  if l:file !~#  '\.dbml$' | let l:file = l:file . '.dbml' | endif

  execute 'edit' l:file
endfunction

""
" Creates the DBDiagram directory.
function! ps#database#CreateDBDiagramDir(fail_silently) abort
  let l:dir = ps#database#GetDBDiagramDirectory()

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
" Creates the sql directory.
function! ps#database#CreateSQLDir(fail_silently) abort
  let l:dir = ps#database#GetSQLDirectory()

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
function! ps#database#GetDBDiagramDirectory()
  if exists('g:db_diagram_directory')
    let l:dir = g:db_diagram_directory
  elseif isdirectory('db')
    let l:dir = 'db/diagrams'
  elseif isdirectory('database')
    let l:dir = 'database/diagrams'
  else
    let l:dir = 'diagrams'
  endif

  return resolve(expand(l:dir)) . '/'
endfunction

""
" Returns the sql directory.
function! ps#database#GetSQLDirectory()
  if exists('g:db_sql_directory')
    let l:dir = g:db_sql_directory
  elseif isdirectory('db')
    let l:dir = 'db/sql'
  elseif isdirectory('database')
    let l:dir = 'database/sql'
  else
    let l:dir = 'sql'
  endif

  return resolve(expand(l:dir)) . '/'
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
function! ps#database#DBDiagramCompletion(arg_lead, cmd_line, cursor_pos)
  let l:dir = ps#database#GetDBDiagramDirectory()
  if !isdirectory(l:dir) | call ps#database#CreateDBDiagramDir(1) | endif
  let l:olddir = chdir(l:dir)
  let l:list = glob('**/*.dbml', 0, 1)
  call chdir(l:olddir)
  return join(l:list, "\n")
endfunction

""
" Completions for SQL Files.
function! ps#database#SQLFileCompletion(arg_lead, cmd_line, cursor_pos)
  let l:dir = ps#database#GetSQLDirectory()
  if !isdirectory(l:dir) | call ps#database#CreateSQLDir(1) | endif
  let l:olddir = chdir(l:dir)
  let l:list = glob('**/*.sql', 0, 1)
  call chdir(l:olddir)
  return join(l:list, "\n")
endfunction

""
" Function for returning completion options, which are the keys to g:db_list.
function! ps#database#ListCompletions(arg_lead, cmd_line, cursor_pos) abort
  if !s:validate() | return | endif

  let l:copy = deepcopy(g:db_list)

  return join(map(l:copy, 'v:val[0]'), "\n")
endfunction

"============="
" PRIVATE API "
"============="

""
" Makes sure g:db_list exists.
function! s:validate() abort
  if exists('g:db_list') && !empty(g:db_list) | return 1 | endif

  call ps#Warn('g:db_list is not set! Please set in `.vimrc` file!')
  return 0
endfunction

function! s:ConfirmProduction()
  if exists('g:db_switch_confirm_production') && !g:db_switch_confirm_production
    return 1
  endif
  return confirm(
          \ 'PRODUCTION, ARE YOU SURE?', "&Yes\n&No\n&Cancel", 2, 'Question'
        \ )
endfunction
