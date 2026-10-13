# polyscene
[![LuaRocks](https://img.shields.io/luarocks/v/little-meow-meow/polyscene)](https://luarocks.org/little-meow-meow/polyscene)
<br /><a href="https://ko-fi.com/little_meow_meow"><img src="https://cdn.prod.website-files.com/5c14e387dab576fe667689cf/670f5a01c01ea9191809398c_support_me_on_kofi_blue.png" height="28px"></a>

> [!IMPORTANT]
> This project was not written with AI and does not accept AI-generated contributions.

## Install
```
$ luarocks install polyscene
```

## Usage
```
Usage: polyscene [-h] {add,remove} <destination> <source> [-y [<yes>]]

transclude the contents of .poly files into other .poly files

Arguments:
   {add,remove}          What to do with the scene
   destination           The .poly file to add the scene into
   source                The .poly file to add into the target .poly

Options:
   -h, --help            Show this help message and exit.
      -y [<yes>],        Skip prompting the user for confirmation
   --yes [<yes>]
```

## Building
```
$ luarocks make polyscene-1.0-0.rockspec
$ luarocks install polyscene-1.0-0.rockspec
```
