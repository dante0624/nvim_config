vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

function _G.MyFoldText()
	local first_line = vim.fn.getline(vim.v.foldstart)
	local last_line = vim.fn.getline(vim.v.foldend):gsub("^%s*", "") -- Removes leading whitespaces
	local line_count = vim.v.foldend - vim.v.foldstart - 1

	-- Normally include the last line in the preview
	-- Unless it is long, then we do not
	if string.len(last_line) > 10 then
		line_count = line_count + 1
		last_line = ""
	end

	local fold_message = ' +--- ' .. line_count .. ' lines ---+ '
	if line_count == 1 then
		fold_message = ' +--- ' .. line_count .. ' line ---+ ' -- Fix plural / singular
	end

    local fold_text =  first_line .. fold_message .. last_line

	-- Turn tabs into appropriate number of spaces
	-- Need to do this now because default behavior later is to turn one tab into one space
	local tab_spaces = string.rep(" ", vim.o.ts)
	return fold_text:gsub("\t",tab_spaces)
end
vim.opt.foldtext = 'v:lua.MyFoldText()'
vim.opt.fillchars:append({fold = " "}) -- Gets rid of trailing dots that vim automatically adds in

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

