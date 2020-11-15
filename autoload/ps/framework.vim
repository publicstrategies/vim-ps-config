function! ps#framework#Rails(...)
  if !has('terminal')
    echom 'Your vim version does not have terminal support.'
    return
  endif

  let l:commands = a:0 == 0 ? 'console' : join(a:000)

  if executable('docker-compose') && filereadable('./docker-compose.yml')
    let l:commands = 'docker-compose run web bundle exec rails ' . l:commands
  elseif executable('bundle') && filereadable('./Gemfile') && isdirectory('./.bundle')
    let l:commands = 'bundle exec rails ' . l:commands
  elseif executable('rails')
    let l:commands = 'rails ' . l:commands
  else
    call ps#Warn("Executable 'rails' not found! Are you in a Rails project?")
    return
  endif

  execute 'botright' 'terminal' l:commands
endfunction

function! ps#framework#Artisan(...)
  if !has('terminal')
    echom 'Your vim version does not have terminal support.'
    return
  endif

  let l:commands = a:0 == 0 ? 'tinker' : join(a:000)

  if !filereadable('./artisan')
    call ps#Warn("Executable 'artisan' not found! Are you in a Laravel project?'")
    return
  elseif filereadable('./docker-compose.yml')
    let l:commands = 'docker-compose run web php artisan ' . l:commands
  else
    let l:commands = 'php artisan ' . l:commands
  endif

  execute 'botright' 'terminal' l:commands
endfunction
