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

-- These options come from Treesitter's README on how to set up folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

function _G.MyFoldText()
	local first_line = vim.fn.getline(vim.v.foldstart)
	local last_line = vim.fn.getline(vim.v.foldend):gsub("^%s*", "") -- Removes leading whitespaces
	local line_count = vim.v.foldend - vim.v.foldstart

	local fold_message = ' +--- ' .. line_count .. ' lines ---+ '
	if line_count == 1 then
		fold_message = fold_message:gsub("lines", "line")
	end

	--[[ If line_count is zero (something went wrong) then first_line==last_line so only display once
	Some buffers can manually set fold_text_bottom to false to hide the last line
		Most buffers don't set it at all, so it will be nil. Then nil==false returns false
		Languages like python should set this in their ftplugin/python.lua file ]]
	if line_count == 0 or vim.b.fold_text_bottom == false then
		last_line = ""
	end

    local fold_text =  first_line .. fold_message .. last_line

	-- Turn tabs into appropriate number of spaces
	-- Need to do this now because default behavior later is to turn one tab into one space
	local tab_spaces = string.rep(" ", vim.o.ts)
	return fold_text:gsub("\t",tab_spaces)
end

vim.opt.foldtext = 'v:lua.MyFoldText()'
vim.opt.fillchars:append({fold = " "}) -- Gets rid of trailing dots that vim automatically adds in


-- Manually ensure that this matches Treesitter's 'ensure_installed'
-- Found under the the plugin configuration
local folding_file_types = {
	'*.lua',
	'*.py',
	'*.java',
	'*.kt',
	'*.html',
	'*.css',
	'*.js',
	'*.json'
}

-- Automatically remembers folds after closing and reopening
local remember_folds = vim.api.nvim_create_augroup('remember_folds', {clear = true})
vim.api.nvim_create_autocmd({'BufWinLeave', 'BufWritePost',}, {
	pattern = folding_file_types,
	group = remember_folds,
	command = "noautocmd silent! mkview",
})

vim.api.nvim_create_autocmd({'BufWinEnter',}, {
	pattern = "*",
	group = remember_folds,
	callback = function()
		vim.cmd([[
			normal zR
			noautocmd silent! loadview
		]])
	end,
})

