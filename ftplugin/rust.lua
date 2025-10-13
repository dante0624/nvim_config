local find_project_root = require("utils.paths").find_project_root
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

local root_dir, is_single_file = find_project_root({
	".git",
	"Cargo.toml",
})

require("lsp.serverCommon").start_or_attach(
	"rustServer",
	root_dir,
	is_single_file
)

require("lsp.serverCommon").start_or_attach(
	"cspellServer",
	root_dir,
	is_single_file
)

-- Run command
vim.b.run_command = "cargo run"
