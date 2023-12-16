require("lsp.languageCommon").start_or_attach(
	"vscode-html-language-server",
	{'--stdio'}
)
require("linting.lintCommon").setup_linters({"htmlhint"})
