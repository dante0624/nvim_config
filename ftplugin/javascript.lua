local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

require("lsp.serverCommon").start_or_attach(
	"javascriptServer",
	root_dir,
	single_file
)
require("linting.lintCommon").setup_linters({ "eslint_d" })

-- %:p expands out to be the complete path to the current buffer
vim.b.run_command = 'node "' .. vim.fn.expand("%:p") .. '"'
