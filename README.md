# vim-ps-config
A plugin for Public Strategies `vim`-users that helps enforce consistency among
developers and across projects by setting things like `expandtab` and indention
levels. It also provides some plugin-style features, such as switching database
URLs for use with the DadBod (db) plugin.

This Readme covers most of the features, but you'll need to read the actual
[documentation](doc/ps_config.txt) if you want everything to be covered.

## Table of Contents
<img
align="right"
src="https://user-images.githubusercontent.com/12698076/93400567-ad2c1280-f845-11ea-8bb1-4a5ba8fde26a.png"
height="350"
width="350"
alt="Vim PS logo with Ruby and React logos"
/>
- [Installation](#installation)
  - [Vim with packages](#vim-with-packages)
  - [Pathogen](#pathogen)
- [Setup](#setup)
  - [Personal vimrc setup](#personal-vimrc-setup)
  - [Project-specific vimrc setup](#project-specific-vimrc-setup)
    - [Automatically Generate Vimrc File](#automatically-generate-vimrc-file)
- [Features](#features)
  - [Switching between database URLs for DadBod access](#switching-between-database-urls-for-dadbod-access)
    - [Manual Swtiching](#manual-switching)
    - [SQL Files and Automatic Database URLs](#sql-files-and-automatic-database-urls)
    - [Automatic Query Generation for SQL Files](#automatic-query-generation-for-sql-files)
  - [Framework Commands](#framework-commands)
  - [Enforcing consistency](#enforcing-consistency)
  - [Features not covered in this readme](#features-not-covered-in-this-readme)
- [Dependencies and Recommended Plugins](#dependencies-and-recommended-plugins)
- [Contributing](#contributing)
  - [Contribution guidelines](CONTRIBUTING.md)

## Installation
### Vim with packages
Clone the repository in your `pack` directory. Note, `public-strategies/` is
used as the package directory in this example, but you can put it in whichever
package directory you want.

```sh
mkdir -p ~/.vim/pack/public-strategies/start/

git clone https://github.com/publicstrategies/vim-ps-config.git \
    ~/.vim/pack/public-strategies/start/vim-psi-config
```

Don't forget the documentation. Run `:helptags` on the `doc/` directory. Or, to
update all your plugins' documentation:

```
:helptags ALL
```

### Pathogen
Clone the repository in `.vim/bundle`.

```sh
git clone https://github.com/publicstrategies/vim-ps-config.git \
    ~/.vim/bundle/vim-psi-config
```

Don't forget the documentation. Run `:helptags` on the `doc/` directory. Or, to
update all your plugins' documentation:

```
:Helptags
```

## Setup
### Personal vimrc setup
A few features will probably suggest for you to use project-specific `.vimrc`
files. To get this to work, in your personal `.vimrc` file, set the option
`exrc`.

```vim
""
" Set in your personal ~/.vimrc or ~/.vim/vimrc file!
set exrc
```

This will source `.vimrc` files in your current directory. If this is a concern
for you, you can still set the options in your personal `.vimrc` file, but it
will be much more difficult to have project-specific settings.

### Project-specific vimrc setup
To enable the plugin for a project, you must set `g:is_ps_project` in your
project's `.vimrc` file.

```vim
""
" Set in .vimrc
let g:is_ps_project = 1
```

It's *strongly* recommended to do this in project-specific `.vimrc` files, but
you *could* put it in your `~/.vimrc` (or `~/.vim/vimrc`). Just be aware that
this plugin will run for every file you open in vim, even if it's not a Public
Strategies project!

#### Automatically Generate Vimrc File
A command exists to help you make your default `.vimrc` file.

```
:PSVimrc
```

This will open a file called `.vimrc` in your current directory, so make sure
you've opened `vim` from within the root of your project, or use the
[vim-rooter](https://github.com/airblade/vim-rooter) plugin. The following text
will be generated inside of `.vimrc`:

```vim
""
" Necessary for the vim-ps-plugin to run. Comment to disable plugin.
let g:is_ps_project = 1

""
" Change the list of consistency settings. The default is what's in the example.
" let g:ps_consistency_settings_list = [
"       \    'nocompatible',
"       \    'expandtab',
"       \  ]

""
" Change the default database. The default is what's in the example.
" let g:db_default_database = 'development'

""
" Change the sql file directory. The default is what's in the example.
" let g:db_sql_directory = '/d\(b\|atabase\)/sql'

""
" Change the list of available database URLs. There is no default.
" let g:db_list = [
"       \    ['development', 'adapter://user:password@host:port/database']
"       \  ]

```

Using the bang version of the command (`:PSVimrc!`) will also save the `.vimrc`
file and reload the plugin.

If you want to set `g:db_list` before reloading the plugin, use the non-bang
version, make your edits, save the file, and then call `:PSReloadPlugin`

There's also a command to create the `sql` directory if it doesn't exist:

```
:DBCreateSQLDir[!] [DIR]
```

If `DIR` is passed, it's used as the directory name. This can included nested
directories, as they will be made with `mkdir -p`. If `DIR` is not passed, the
plugin will use `g:db_sql_directory` if it exists. If `!` is used, errors will
be suppressed.

If you want to run both `:PSVimrc` and `:DBCreateSQLDir!` to set up all the
infrastructure at the same time, a command exists for that:

```
:PSNewProject[!]
```

If `!` is used, `:PSVimrc!` will be called (with a bang).

## Features
### DadBod Extended Functionality
The following features are an extension of Tim Pope's
[vim-dadbod](https://github.com/tpope/vim-dadbod). If you don't use `DadBod`,
or just want to disable the functionality, set the following in your personal
`.vimrc` file:

```vim
let g:ps_config_use_dadbod = 0
```

#### Switching between database URLs for DadBod access
In your project, there should exist a `.vimrc` file. In that file, you should
define a 2-D list called `g:db_list`. The "keys" will be used as an identifier
when setting the URLs. They will also used for tab-completion. The values
should be database URLs to those databases. Here's an example:

```vim
let g:db_list = [
      \   ['testing',        'postgres://user:password@host:port/database'],
      \   ['development',    'postgres://user:password@host:port/database'],
      \   ['staging',        'postgres://user:password@host:port/database'],
      \   ['production',     'postgres://user:password@host:port/database'],
      \   ['mysql_testing',     'mysql://user:password@host:port/database'],
      \   ['mysql_development', 'mysql://user:password@host:port/database'],
      \   ['mysql_staging',     'mysql://user:password@host:port/database'],
      \   ['mysql_production',  'mysql://user:password@host:port/database']
      \ ]
```

Key names should follow the above naming convention. Note the `mysql` prefix is
used to match sub-directories of `db/sql/` and set the database URLs of the
files accordingly. See [SQL Files and Automatic Database
URLs](#sql-files-and-automatic-database-urls) for more details.

You can define a default database by setting `g:db_default_database` in the
project's `.vimrc`.

```vim
let g:db_default_database = 'development'
```

If `g:db_default_database` is not defined, but 'development' exists as a key, it
will be the default database. Otherwise, the first database in the list will be
the default. This is why we use a 2-D list instead of a dictionary; dictionaries
are not ordered in vimscript.

If, at any time, you want to see which database is being used, use the `:DBList`
command. If you use the naming convention previously explained, if the current
DB URL is set to a production database, it will be in red. The `DBList!` version
of the command will also show the actual DB URL.

```
:DBList
"=> b:db is set to mysql

:DBList!
"=> b:db is set to mysql: mysql://user:password@host:port/database
```

#### Manual Switching
Still assuming the above example list, switching DBs is now as easy as calling
`:DBSwitch mysql_development`. This feature has tab-completion, so you can type
`:DBSwitch <tab>` and it will show/cycle the options. `DBSwitch` with no
arguments will switch to `g:db_default_database`.

If you attempt to switch to a production database, and assuming you named your
keys correctly, you will be asked to confirm the change. To avoid this
confirmation, use the bang version of the command.

```
:DBSwitch! production
```

To learn about database URLs, read the [help
documentation](https://github.com/tpope/vim-dadbod/blob/master/doc/dadbod.txt)
for `DadBod`.

#### SQL Files and Automatic Database URLs
In most of our projects, we keep a directory for storing common `sql`
queries for tables. The directory is usually one of the following:

|Rails|Laravel|
|-----|-------|
|`db/sql/`|`database/sql/`|

When opened, files in this directory will automatically be set to the default
database (either "development" if it exists, or the first database listed in
`g:db_list`). If, however, the file is in a sub-directory, and that
sub-directory matches a key in `g:db_list`, the database URL will be set to that
key's value.

Assuming a **Rails project's** `.vimrc` contains the following:

```vim
let g:db_list = [
      \   ['development',       'postgres://user@host/database'],
      \   ['mysql_development', 'mysql://user:password@host:port/database']
      \ ]
```

A file called `db/sql/users.sql` would point to
`postgres://user@host/database`. This would also be true if the file were called
`db/sql/development/users.sql`. If we want the URL to point to
`mysql://user:password@host:port/database`, we'd need to call the file
`db/sql/mysql_development/users.sql`. If you call the sub-directory `mysql`
instead of `mysql_development`, the `_development` suffix will be implied. Note that
you can still change the database URL with `DBSwitch`.

You can change the path to the `.sql` files by setting `g:db_sql_directory` to a
string. For example, here is the default path:

```vim
let g:db_sql_directory = '/d\(b\|atabase\)/sql'
```

Note the escaping of special characters.

#### Automatic Query Generation for SQL Files
Any new or empty `db/sql/**/*.sql` file opened with vim will automatically have
default queries generated in the file. It is assumed that the file name will be
the table name to query. These queries are even adapter aware, which as we've
learned, are based off the directory in which they reside. Assuming the file
name is `users.sql`:

If the adapter is postgres, the following contents will be placed in the file:
```sql
-- List all tables in the database.
\dt;

-- Describe 'users' table's attributes.
\d users;

-- List all records from the 'users' table.
select * from users;
```

If the adapter is mysql, the following contents will be placed in the file:
```sql
-- List all tables in the database.
show tables;

-- Describe 'users' table's attributes.
describe users;

-- List all records from the 'users' table.
select * from users;
```

There are also commands provided for generating this sql at-will. Using the `!`
form will place text *above* current cursor position. Note that a database URL
must be set.

```
:DBGenerateSQL[!] [TABLE]
```

### Framework Commands
For Rails and Laravel projects, commands exist to leverage vim's terminal
feature to call rails and artisan. These are docker-aware, and will use
docker-compose if in a Docker environment. If no arguments are passed, a REPL is
opened. For example, to run the tests for a project, it's as simple as:

```
:PSRails test
:PSArtisan test
```

Note that all these plugins do is provide wrappers for the rails and artisan
commands, and are NOT meant to replace the far-more advanced vim-rails and
vim-laravel plugins.

### Enforcing Consistency
In the [ftplugin directory](ftplugin/), we specify settings based on filetype,
such as indention levels.

Other settings that get enabled (unless disabled via the variable below):
- `expandtab` - Tabs are automatically changed to spaces.

You can add to this list on a per-project basis by setting the following value
in your project's `.vimrc` file:

```vim
let g:ps_consistency_settings_list = ['backspace=2', 'wrapscan']
```

Note that the elements must be valid arguments for `set`, wrapped in quotes.

Consistency settings can be disabled by adding the following to your personal
`.vimrc` file:

```vim
let g:ps_config_use_consistency = 0
```

### Features not Covered in this Readme
Read the `:help` documentation for the following features:
- `ps-notes`
- `ps-rest`
- `ps-dbml`

## Dependencies and Recommended Plugins:
- [vim-dadbod](https://github.com/tpope/vim-dadbod) is needed for DadBod's
extended features.
- [vim-rest-console](https://github.com/diepm/vim-rest-console) is used for API
calls through vim.
- [DBML Syntax](https://github.com/jidn/vim-dbml) for DBML files. We use [this
site](dbdiagram.io) for visualization.

## Contributing
See the [contribution guidelines](CONTRIBUTING.md).
