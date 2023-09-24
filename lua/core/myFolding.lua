require("core.myFoldingKeymaps")

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

