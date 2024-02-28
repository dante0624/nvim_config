local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()

require("lsp.languageCommon").start_or_attach(
	"pyright-langserver",
	root_dir,
	single_file
)
require("linting.lintCommon").setup_linters({ "ruff" })

-- Buffer scoped variable that I made up for folding
vim.b.fold_text_bottom = false

-- Run command
vim.b.run_command = 'python "' .. vim.fn.expand("%:p") .. '"'
