local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

require("lsp.serverCommon").start_or_attach(
	"cssServer",
	root_dir,
	single_file
)
require("linting.lintCommon").setup_linters({ "stylelint" })
