--[[ Fixes a strange issue with neovim folding
For some reason, folds are computed initially, but not recomputed after the buffer is modified

For example, lets say we open a new buffer with the following lines:
	1  if true then
	2      print("hello")
	3  end
Then vim will correctly compute that lines 1-3 should be folded,
assuming we are using the syntax or expr (treesitter) folding methods.

But, lets say we add a new line in the middle:
	1  if true then
	2      print("hello")
	3      print("world")
	4  end
For some reason vim will still think that only lines 1-3 should be folded, leading to an incorrect fold

One way to fix this is to save the buffer, and then reload with :e
But usually we do not want to save just because we are folding!

A strange solution is that changing the foldmethod with vim.o.foldmethod = "method"
will force a recomputation of what needs to be folded.
This even works if we set this option back to the value that it originally had!

So, below is a script which forces this trick to happen before all folding keybinds]]

-- Assume that lhs and rhs are both strings
-- We will wrap the rhs in a folding reset
local function fold_keymap(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(
		mode,
		lhs,
		function()
			local method = vim.o.foldmethod
			vim.opt.foldmethod = method

			-- The exclamation point means to not use remappings
			-- Important, because without it we would have infinite recursion
			-- It would which would crash vim
			vim.cmd("normal! " .. rhs)
		end,
		options
	)
end

fold_keymap('', 'zz', 'za')
fold_keymap('', 'ze', ']z')
fold_keymap('', 'zb', '[z')

fold_keymap('', 'za', 'za')
fold_keymap('', 'zo', 'zo')
fold_keymap('', 'zO', 'zO')
fold_keymap('', 'zc', 'zc')
fold_keymap('', 'zC', 'zC')
fold_keymap('', 'zR', 'zR')
fold_keymap('', 'zM', 'zM')


-- Set the folding filetype based on filetype
local fold_method_picker = vim.api.nvim_create_augroup('fold_method_picker', {clear = true})

-- These filetypes do not have good tressiter parsers, but have good builtin syntax parsers
local syntax_filetypes = {
	"*.json",
}

-- Manually ensure that this matches Treesitter's 'ensure_installed'
-- Found under the the plugin configuration
local treesitter_expr_filetypes = {
	'*.lua',
	'*.py',
	'*.java',
	'*.kt',
	'*.html',
	'*.css',
	'*.js',
}

-- Autocommands go off in the order they are specified
-- So we default to manual, but have tressiter_expr or syntax as specific options
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
	pattern = '*',
	group = fold_method_picker,
	command = "set foldmethod=manual",
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
	pattern = syntax_filetypes,
	group = fold_method_picker,
	command = "set foldmethod=syntax",
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
	pattern = treesitter_expr_filetypes,
	group = fold_method_picker,
	command = "set foldmethod=expr",
})

-- These options come from Treesitter's README on how to set up folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false


-- Set custom text which appears whenever we have a fold
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


-- Automatically remembers folds after closing and reopening
local remember_folds = vim.api.nvim_create_augroup('remember_folds', {clear = true})
local folding_file_types = vim.tbl_extend("force", syntax_filetypes, treesitter_expr_filetypes)

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
			normal! zR
			noautocmd silent! loadview
		]])
	end,
})

