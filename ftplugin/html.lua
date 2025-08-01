local find_project_root = require("utils.paths").find_project_root
local folding = require("core.myModules.folding")

local root_dir, single_file = find_project_root()

folding.setup_treesitter_folding()

require("lsp.serverCommon").start_or_attach(
	"htmlServer",
	root_dir,
	single_file
)

require("lsp.serverCommon").start_or_attach(
	"cspellServer",
	root_dir,
	single_file
)
