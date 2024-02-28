local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()

require("lsp.languageCommon").start_or_attach(
	"vscode-html-language-server",
	root_dir,
	single_file
)
require("lsp.languageCommon").start_or_attach("vscode-html-language-server")
require("linting.lintCommon").setup_linters({ "htmlhint" })
