require("lsp.languageCommon").start_or_attach(
	"vscode-css-language-server",
	{'--stdio'}
)
require("linting.lintCommon").setup_linters({"stylelint"})

