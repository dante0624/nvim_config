local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()

require("lsp.serverCommon").start_or_attach(
	"pythonServer",
	root_dir,
	single_file
)
require("linting.lintCommon").setup_linters({ "ruff" })

-- Check if the first line of a fold ends with ":"
-- If it does, then don't include the last line in the fold text
vim.b.fold_last_line = function(fold_start_number, _)
	return vim.fn.getline(fold_start_number):sub(-1, -1) ~= ":"
end

-- Run command
vim.b.run_command = 'python "' .. vim.fn.expand("%:p") .. '"'
