require("lsp.languageCommon").start_or_attach(
	"typescript-language-server",
	{'--stdio'}
)
require("linting.lintCommon").setup_linters({"eslint_d"})

-- %:p expands out to be the complete path to the current buffer
vim.b.run_command = 'node "'..vim.fn.expand('%:p')..'"'

