--[[ Fixes a strange issue with neovim folding
Folds are computed initially, but not recomputed after the buffer is modified

For example, lets say we open a new buffer with the following lines:
	1  if true then
	2      x = 1
	3  end
Then vim will correctly compute that lines 1-3 should be folded,
assuming we are using the syntax or expr (treesitter) folding methods.

But, lets say we add a new line in the middle:
	1  if true then
	2      x = 1
	3      y = 2
	4  end
Still, vim will think that only lines 1-3 should be folded.
This leads to an incorrect and confusing fold:

One way to fix this is to save the buffer, and then reload with :e
But usually we do not want to save just because we are folding!

A strange solution is that updating the foldmethod with
vim.o.foldmethod = "method" will force vim to recompute folds.
This even works if we set the option to its current value!

We use this trick before all folding keybinds]]

-- Assume that lhs and rhs are both strings
-- We will wrap the rhs in a folding reset
local function fold_keymap(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, function()
		local method = vim.o.foldmethod
		vim.opt.foldmethod = method

		-- The exclamation point means to not use remappings
		-- No exclamation point would be infinite recursion,
		-- and would which would crash vim
		vim.cmd("normal! " .. rhs)
	end, options)
end

fold_keymap("", "zz", "za")
fold_keymap("", "ze", "]z")
fold_keymap("", "zb", "[z")

fold_keymap("", "za", "za")
fold_keymap("", "zo", "zo")
fold_keymap("", "zO", "zO")
fold_keymap("", "zc", "zc")
fold_keymap("", "zC", "zC")
fold_keymap("", "zR", "zR")
fold_keymap("", "zM", "zM")

-- Set the folding filetype based on filetype
local fold_method = vim.api.nvim_create_augroup("fold_method", { clear = true })

-- These filetypes do not have good tressiter parsers,
-- but they have good builtin syntax parsers
local syntax_patterns = {
	"*.json",
}

-- Manually ensure that this matches Treesitter's 'ensure_installed'
-- Found under the the plugin configuration
local expr_patterns = {
	"*.lua",
	"*.py",
	"*.java",
	"*.kt",
	"*.html",
	"*.css",
	"*.js",
}

-- Autocommands go off in the order they are specified
-- So we default to manual, but can specify treesitter_expr or syntax
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*",
	group = fold_method,
	command = "set foldmethod=manual",
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = syntax_patterns,
	group = fold_method,
	command = "set foldmethod=syntax",
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = expr_patterns,
	group = fold_method,
	command = "set foldmethod=expr",
})

-- These options come from Treesitter's README on how to set up folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-- Set custom text which appears whenever we have a fold
function _G.MyFoldText()
	local first_line = vim.fn.getline(vim.v.foldstart)

	-- Removes leading whitespaces
	local last_line = vim.fn.getline(vim.v.foldend):gsub("^%s*", "")
	local line_count = vim.v.foldend - vim.v.foldstart

	local fold_message = " +--- " .. line_count .. " lines ---+ "
	if line_count == 1 then
		fold_message = fold_message:gsub("lines", "line")
	end

	--[[ Two scenerios for not including the last line:
		If line_count is zero then first_line==last_line.
			But we only want to show this line once
		Some filetypes look better like this (python)
			These buffers can manually set fold_text_bottom to false]]
	if line_count == 0 or vim.b.fold_text_bottom == false then
		last_line = ""
	end

	local fold_text = first_line .. fold_message .. last_line

	-- Turn tabs into appropriate number of spaces
	-- If we don't do this, the foldtext turns 1 tab into 1 space
	local tab_spaces = string.rep(" ", vim.o.ts)
	return fold_text:gsub("\t", tab_spaces)
end

vim.opt.foldtext = "v:lua.MyFoldText()"

-- Get rid of trailing dots that vim automatically adds in
vim.opt.fillchars:append({ fold = " " })

-- Automatically remembers folds after closing and reopening
local remember = vim.api.nvim_create_augroup("remember", { clear = true })
local all_patterns = vim.tbl_extend("force", syntax_patterns, expr_patterns)

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
	pattern = all_patterns,
	group = remember,
	command = "noautocmd silent! mkview",
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*",
	group = remember,
	callback = function()
		vim.cmd([[
			normal! zR
			noautocmd silent! loadview
		]])
	end,
})
