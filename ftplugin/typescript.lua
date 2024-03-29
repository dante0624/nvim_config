local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()

require("lsp.serverCommon").start_or_attach(
	"typescriptServer",
	root_dir,
	single_file
)

-- %:p expands out to be the complete path to the current buffer
vim.b.run_command = 'npx tsx "' .. vim.fn.expand("%:p") .. '"'

