vim.o.foldmethod = "indent"

-- We want to only remember folds on these file types
	-- Each call to 'mkview' creates a tmp file
-- Also having folds at all looks kinda bad on things that aren't source files
local folding_file_types = {
	'*.lua',
	'*.python',
	'*.java',
	'*.json',
	'*.html',
	'*.css',
	'*.js',
}

-- Automatically remembers folds after closing and reopening
local remember_folds = vim.api.nvim_create_augroup('remember_folds', {clear = true})
vim.api.nvim_create_autocmd({'BufWinLeave'}, {
	pattern = folding_file_types,
	group = remember_folds,
	command = "mkview",
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
	-- First open all the folds that exist (zR)
	-- Next, try to load any folds that exist, and do it silently so if they don't exist then nothing happens
	-- This applies to any file at all
	-- So we have the behavior where we remember folds if possible, but if not possible then they are all open
	pattern = "*",
	group = remember_folds,
	callback = function()
		vim.cmd([[
			normal zR
			silent! loadview
		]])
	end,
})

