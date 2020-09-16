""
" Set the settings found in g:ps_consistency_settings_list, or defaults.
function! consistency#SetConsistentSettings()
  let l:settings = s:ConsistencyDefaults()

  if exists('g:ps_consistency_settings_list')
    call extend(l:settings, g:ps_consistency_settings_list)
  endif

  for l:setting in l:settings | execute 'set' l:setting | endfor
endfunction

" PRIVATE API

""
" The default consistency settings.
function! s:ConsistencyDefaults()
  return [
        \    'nocompatible',
        \    'expandtab',
        \ ]
endfunction
