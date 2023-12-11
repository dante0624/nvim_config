require("lsp.languageCommon").start_or_attach(
	"pyright-langserver",
	{'--stdio'}
)

-- Buffer scoped variable that I made up for folding
vim.b.fold_text_bottom = false

-- Python only tab options
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_nested_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth() * 2'

vim.b.run_command = 'python "'..vim.fn.expand('%:p')..'"'

