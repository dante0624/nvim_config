local find_project_root = require("utils.paths").find_project_root
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

local root_dir, is_single_file = find_project_root()

require("lsp.serverCommon").start_or_attach(
	"typescriptServer",
	root_dir,
	is_single_file
)

require("lsp.serverCommon").start_or_attach(
	"cspellServer",
	root_dir,
	is_single_file
)

-- %:p expands out to be the complete path to the current buffer
vim.b.run_command = 'npx tsx "' .. vim.fn.expand("%:p") .. '"'

-- Use 2 spaces instead of tabs (prettier preferences)
vim.bo[0].tabstop = 2
vim.bo[0].shiftwidth = 2
vim.bo[0].expandtab = true
