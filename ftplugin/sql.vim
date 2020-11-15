if ps#CanUseConsistency()
  setlocal tabstop=2 shiftwidth=2 softtabstop=2
endif

if ps#CanUseDadbod()
  let s:db_sql_directory = ps#database#GetSQLDirectory()
  let s:dir_name = fnamemodify(resolve(expand('%:p')), ':h') . '/'

  if match(s:dir_name, s:db_sql_directory) >= 0
    if !exists('g:db_list')
      call ps#Warn("g:db_list not set. Can't set URL.")
    else
      if !isdirectory(s:dir_name) | call mkdir(s:dir_name, 'p') | endif
      let b:db = ps#database#FindDBByKey(split(s:dir_name, '/')[-1], 1, g:db)
      if getfsize(@%) <= 0 | call ps#database#GenerateSQL(1) | endif
    endif
  endif
endif
