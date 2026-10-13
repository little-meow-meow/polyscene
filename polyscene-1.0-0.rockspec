package = "polyscene"
version = "1.0-0"
source = {
	url = "git://github.com/little-meow-meow/polyscene.git"
}
description = {
	summary = "A CLI tool for transcluding Polytoria worlds",
	-- detailed = [[
	-- 	TODO: Write a detailed description
	-- ]],
	-- homepage = "http://leafo.net/lua-enet",
	-- license = "MIT"
}
dependencies = {
	"lua >= 5.1",
    "argparse",
    "json.lua >= 0.1.3",
    "lua-zstd >= 0.2.0-1",
}
external_dependencies = {}
build = {
	type = "builtin",
	modules = {
		polyscene = "polyscene.lua"
	}
}