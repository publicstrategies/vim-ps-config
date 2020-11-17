""
" Don't reload load the plugin.
if get(g:, 'ps_loaded_config') || &cp | finish | endif
let g:ps_loaded_config = 1

""
" Populate create .vimrc and populate its contents.
" If ! is used, saves .vimrc file and re-loads plugin.
command! -bang PSVimrc call ps#Vimrc(<bang>0)

""
" Sets up project infrastructure.
" If ! is used, saves .vimrc file and re-loads plugin.
command! -bang PSNewProject call ps#NewProject(<bang>0)

""
" Reload the plugin.
" If ! is used, also reloads the project's .vimrc if it exists.
command! PSReloadPlugin call ps#ReloadPlugin()

""
" Updates the plugin.
command! PSUpdatePlugin call ps#UpdatePlugin()

""
" If we're not in a PS project, quit loading the plugin.
if !ps#IsPsProject() | finish | endif

if ps#CanUseFrameworkCommands()
  ""
  " Wrapper for rails that understands docker and bundler.
  command! -nargs=* -complete=file PSRails call ps#framework#Rails(<f-args>)
  ""
  " Wrapper for Artisan that understands docker.
  command! -nargs=* -complete=file PSArtisan call ps#framework#Artisan(<f-args>)
endif

""
" Add consistency settings. Can be disabled by setting:
"    let g:ps_config_use_consistency = 0
" in your .vimrc
if ps#CanUseConsistency()
  call ps#consistency#SetConsistentSettings()
endif

if ps#CanUseRest()
  ""
  " Sign in. If ! is used, will also echo the token.
  command! -nargs=? -bang PSSignIn call ps#rest#SignIn(<bang>0, <f-args>)

  ""
  " Open rest file.
  command! -nargs=+ -complete=custom,ps#rest#FileCompletion PSRest call
        \ ps#OpenFile(ps#rest#GetRestDir(), <f-args>, 'rest')

  ""
  " Provide a command to generate rest files. Add ! to place above cursor.
  " Example: `:PSGenerateRest users`
  command! -bang -nargs=? PSGenerateRest
        \ call ps#rest#GenerateRest(<bang>0, <f-args>)
endif

if ps#CanUseNotes()
  command! -nargs=+ -complete=custom,ps#notes#NoteFileCompletion PSNote
        \ call ps#notes#File(<f-args>)
endif

""
" If you don't use DadBod, and want the functionality disabled, you can set
"    let g:ps_config_use_dadbod = 0
" in your .vimrc file.
if ps#CanUseDadbod()
  ""
  " IF the user hasn't defined which table is the default, assume 'development'.
  if !exists('g:db_default_database')
    let g:db_default_database = 'development'
  endif

  ""
  " Open database file.
  command! -nargs=+ -complete=custom,ps#database#SQLFileCompletion DBFile
        \ call ps#OpenFile(ps#database#GetSQLDir(), <f-args>, 'sql')

  ""
  " Open database file.
  command! -nargs=+ -complete=custom,ps#database#DBDiagramCompletion DBDiagram
        \ call ps#OpenFile(ps#database#GetDBDiagramDir(), <f-args>, 'dbml')

  ""
  " If g:db isn't set, but g:db_list is, set g:db to g:db_default_database.
  " If that key doesn't exist, set g:db to the first db in the list.
  if !exists('g:db') && exists('g:db_list')
    let g:db = ps#database#FindDBByKey(g:db_default_database, 0, g:db_list[0][1])
  endif

  ""
  " Provide a command to call the switch db function.
  " If no arg is passed, defaults to g:db_default_database.
  " Example: `:DBSwitch test`
  "       => Switching to test database
  command! -bang -nargs=? -complete=custom,ps#database#ListCompletions DBSwitch
        \ call ps#database#DBSwitch(<bang>0, <f-args>)

  ""
  " Provide a command to show the current db url. Add ! to show actual URL
  " Example: `:DBList!`
  "       => g:db is set to development: postgres://user@host/database
  command! -bang DBList call ps#database#DBList(<bang>0)

  ""
  " Provide a command to generate SQL. Add ! to place above cursor.
  " Example: `:DBGenerateSQL users`
  "       => Default SQL queries for 'users' would be added to file.
  command! -bang -nargs=? DBGenerateSQL
        \ call ps#database#GenerateSQL(<bang>0, <f-args>)

  ""
  " Provide a command to generate Diagrams. Add ! to place above cursor.
  " Example: `:DBGenerateDiagram users`
  "       => Default SQL queries for 'users' would be added to file.
  command! -bang -nargs=? DBGenerateDiagram
        \ call ps#database#GenerateDBDiagram(<bang>0, <f-args>)
endif
