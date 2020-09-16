""
" Don't load this plugin if the user has it disabled, or it's already been
" loaded, or if there are errors in the error list.
if (exists('g:ps_loaded_config') && g:ps_loaded_config) || &cp
  finish
endif
let g:ps_loaded_config = 1

""
" Populate create .vimrc and populate its contents.
" If ! is used, saves .vimrc file and re-loads plugin.
command! -bang PSVimrc call ps#Vimrc(<bang>0)

""
" Sets up project infrastructure.
" Calls :PSVimrc!, :DBCreateSQLDir!
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
  command! -nargs=* -complete=file PSRails call framework#Rails(<f-args>)
  ""
  " Wrapper for Artisan that understands docker.
  command! -nargs=* -complete=file PSArtisan call framework#Artisan(<f-args>)
endif

if ps#CanUseCurl()
  command! PSCurl call ps#Curl()
endif

""
" Add consistency settings. Can be disabled by setting:
"    let g:ps_config_use_consistency = 0
" in your .vimrc
if ps#CanUseConsistency()
  call consistency#SetConsistentSettings()
endif

if ps#CanUseNotes()
  command! -nargs=+ -complete=custom,notes#NoteFileCompletion
        \ PSNote call notes#File(<f-args>)
  command! -bang PSCreateNotesDir call notes#CreateNotesDir(<bang>0)
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
  " Creates the SQL dir.
  " If ! is used, will silence warnings.
  command! -bang DBCreateSQLDir call database#CreateSQLDir(<bang>0)

  ""
  " Open database file.
  command! -nargs=+ -complete=custom,database#SQLFileCompletion
        \ DBFile call database#File(<f-args>)

  ""
  " Open database file.
  command! -nargs=+ -complete=custom,database#DBDiagramCompletion
        \ DBDiagram call database#DBDiagram(<f-args>)

  ""
  " If g:db isn't set, but g:db_list is, set g:db to g:db_default_database.
  " If that key doesn't exist, set g:db to the first db in the list.
  if !exists('g:db') && exists('g:db_list')
    let g:db = database#FindDBByKey(g:db_default_database, 0, g:db_list[0][1])
  endif

  ""
  " Provide a command to call the switch db function.
  " If no arg is passed, defaults to g:db_default_database.
  " Example: `:DBSwitch test`
  "       => Switching to test database
  command! -bang -nargs=? -complete=custom,database#ListCompletions
        \ DBSwitch call database#DBSwitch(<bang>0, <f-args>)

  ""
  " Provide a command to show the current db url. Add ! to show actual URL
  " Example: `:DBList!`
  "       => g:db is set to development: postgres://user@host/database
  command! -bang DBList call database#DBList(<bang>0)

  ""
  " Provide a command to generate SQL. Add ! to place above cursor.
  " Example: `:DBGenerateSQL users`
  "       => Default SQL queries for 'users' would be added to file.
  command! -bang -nargs=? DBGenerateSQL call database#GenerateSQL(<bang>0, <f-args>)

  ""
  " Provide a command to generate Diagrams. Add ! to place above cursor.
  " Example: `:DBGenerateDiagram users`
  "       => Default SQL queries for 'users' would be added to file.
  command! -bang -nargs=? DBGenerateDiagram call database#GenerateDBDiagram(<bang>0, <f-args>)
endif