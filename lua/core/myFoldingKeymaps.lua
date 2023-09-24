local Map = require("utils.map").Map
local Local_Map = require("utils.map").Local_Map

--[[ Treesitter initially parses where all folds should be perfectly a buffer first opens
But sometimes if a newline is added, the new lines that should be folded don't get updated
Hacky solution to make treesitter re-parse where the folds should be.
Just set the foldmethod to expr again]]
local reset_expr = '<Cmd>set foldmethod=expr<CR>'
Map('', 'zz', reset_expr..'za')
Map('', 'ze', reset_expr..']z')
Map('', 'zb', reset_expr..'[z')

Map('', 'za', reset_expr..'za')
Map('', 'zo', reset_expr..'zo')
Map('', 'zO', reset_expr..'zO')
Map('', 'zc', reset_expr..'zc')
Map('', 'zC', reset_expr..'zC')
Map('', 'zR', reset_expr..'zR')
Map('', 'zM', reset_expr..'zM')

-- Treesitter doesn't work with making folds for json files
-- So we use foldmethod=syntax instead, because json has a simple syntax and this works
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
	pattern = { "*.json" },
	callback = function()
		vim.opt.foldmethod="syntax"

		local reset_syntax = '<Cmd>set foldmethod=syntax<CR>'
		Local_Map('', 'zz', reset_syntax..'za')
		Local_Map('', 'ze', reset_syntax..']z')
		Local_Map('', 'zb', reset_syntax..'[z')
		Local_Map('', 'za', reset_syntax..'za')
		Local_Map('', 'zo', reset_syntax..'zo')
		Local_Map('', 'zO', reset_syntax..'zO')
		Local_Map('', 'zc', reset_syntax..'zc')
		Local_Map('', 'zC', reset_syntax..'zC')
		Local_Map('', 'zR', reset_syntax..'zR')
		Local_Map('', 'zM', reset_syntax..'zM')
	end
})

