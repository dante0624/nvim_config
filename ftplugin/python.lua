local Local_Map = require("utils.map").Local_Map

-- Buffer scoped variable that I made up for folding
vim.b.fold_text_bottom = false

-- Python only tab options
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_nested_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth() * 2'

-- %:p expands out to be the complete path to the current buffer
local full_fname = vim.fn.expand('%:p')

local command = 'python "'..full_fname..'"'-- Wrap out file name in double quotes
Local_Map(
	{ 'n', 'v' },
	'<Leader><CR>',
	'<Cmd>ToggleTerm<CR>'..command..'<CR>'
)

