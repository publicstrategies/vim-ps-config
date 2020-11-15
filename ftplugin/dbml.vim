if ps#CanUseConsistency()
  setlocal tabstop=2 shiftwidth=2 softtabstop=2
endif

if ps#CanUseDadbod()
  let s:db_diagram_directory = ps#database#GetDBDiagramDirectory()
  let s:dir_name = fnamemodify(resolve(expand('%:p')), ':h') . '/'

  if match(s:dir_name, s:db_diagram_directory) >= 0
    if !isdirectory(s:dir_name) | call mkdir(s:dir_name, 'p') | endif
    if getfsize(@%) <= 0 | call ps#database#GenerateDBDiagram(1) | endif
  endif
endif
