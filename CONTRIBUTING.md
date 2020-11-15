# Contributing
Basically, if you have a configuration, and you think it could be useful to
others, add it. Just keep the following things in mind:
- [Do not add key mappings](#do-not-add-key-mappings)
- [Make it customizable](#make-it-customizable)
- [Add a way to disable the feature](#add-a-way-to-disable-the-feature)
- [Keep the plugin file clean](#keep-the-plugin-file-clean)
- [Properly scope variables](#properly-scope-variables)
- [If you do not know vimscript, join the club](#if-you-do-not-know-vimscript)
- [If you find things that could be done better](#if-you-find-things-that-could-be-done-better)

## Do not add key mappings
We want to enable users, not mess with their configurations. For access to
features, provide commands rather than key mappings. If the user wants a
mapping, they can map it to call command you provide. You can see an example of
how to make a command in the [main plugin file](plugin/ps_config.vim), or
with `:help command`.

## Make it customizable
Don't assume you know what will always be the best option. If you have a list of
defaults for a feature, consider making it into a global variable the user can
change in their `.vimrc`. For example, the `g:ps_consistency_settings_list` list
allows the user to override what the plugin has as the default, and the
`g:db_sql_directory` list allows the `.sql` file location to be set on a
per-project basis.

## Add a way to disable the feature
Since this is an all-in-one plugin, we don't want to force people to use
features they don't want. When adding a feature, give them a way to disable it.
This should be in the form of a global variable that the user sets in their
`.vimrc`, and should be prefixed with `ps_config_use_`. Your code should check
for the existence of this variable, and if it's set to `false` (`0`), don't load
your feature. I've added some functions in the [shared autoload
file](autoload/ps.vim) that help with this.

Note that all following examples assume the new feature is called
`MyNewFeature`. Make sure to replace this string with your feature name.

First, add a new function in `autoload/ps.vim`

```vim
""
" True if is_ps_project is true, and my new feature isn't disabled.
function! ps#CanUseMyNewFeature() abort
  ""
  " NOTE s:VarNotDisabled() is a helper function in the shared autoload file.
  "      Pass your feature-enable variable to it *as a string*.
  return s:VarNotDisabled('g:ps_config_use_my_new_feature')
endfunction
```

Then, in your code where the feature actually lives, wrap it in a conditional.

```vim
if ps#CanUseMyNewFeature()
  ""
  " code for 'my new feature' goes here...
endif
```

OR, if a whole file is to be loaded (like an `ftplugin`, etc.), put a guard
clause at the top of the file that uses `finish` to not load the rest of the
file. Notice, we invert the function call!

```vim
if !ps#CanUseMyNewFeature()
  finish
endif
""
" code for 'my new feature' goes here...
```

If you provide a command to trigger your feature, put it in the [plugin
file](plugin/ps_config.vim), and also wrap it in a conditional

```vim
if ps#CanUseMyNewFeature()
  command! MyNewFeature call ps#my_new_feature#MyNewFeature()
endif
```

## Keep the plugin file clean
The `plugin/ps_plugin.vim` should be simple, only calling `autoload` functions.
This will keep the plugin load as light as possible. If your feature needs to
call functions, put them in a new `autoload` file for your feature.

```
:e autoload/my_new_feature.vim
```

If the function can be shared by other features, put it in the [shared autload
file](autoload/ps.vim).
You can view examples of how `autoload` functions work in the [Switch DB autoload
file](autoload/database.vim). If you're still having trouble, try `:help autoload`.

## Properly scope variables
Vimscript has a lot of ways to scope variables. Make sure you utilize this, as
to not pollute the users' sessions. Also utilize `setlocal` as opposed to `set`
when appropriate.

```
:help internal-variables
:help set
:help setlocal
```

Also, a variable set with no scope prefix is local to the function in which it's
set, or global when not set in a function. Even so, try to always explicitly set
the scope, as it makes it easier to tell what's going on at a glance.

## If you do not know vimscript
Join the club.

Feel free to ask me (Evan) for help, but I'm by no means actually good at it. I
will help as much as I can, when I can. It's *very* hard to find answers to
questions online about vimscript. The best tutorial I've found is [Learn
VimScript the Hard Way](https://learnvimscriptthehardway.stevelosh.com/); it
covers the basics, but don't expect to come out a master. Other than that, the
`vim` documentation can help, but is extremely cumbersome (try `:help map()` for
example). Lastly, I recommend just reading through some of [Tim Pope's
plugins](https://github.com/tpope?utf8=%E2%9C%93&tab=repositories&q=&type=&language=vim+script).
I'd honestly say that's what's helped me the most.

Godspeed.

## If you find things that could be done better
I fully admit I don't know vimscript very well, so if you see mistakes, or ways
in which the plugin can improve, *please* submit a Merge Request!
