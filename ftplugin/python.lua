-- TODO:
-- Replace this with the other LSP
require("lsp.languageCommon").start_or_attach(
	"pyright-langserver",
	{'--stdio'}
)
require("linting.lintCommon").setup_linters({
	"flake8",
	"pydocstyle",
})

-- Buffer scoped variable that I made up for folding
vim.b.fold_text_bottom = false

-- Run command
vim.b.run_command = 'python "'..vim.fn.expand('%:p')..'"'

