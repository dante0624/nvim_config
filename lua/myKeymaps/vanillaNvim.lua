local Map = require("utils.map").Map

-- Maps leader to the spacebar (pretty universal)
Map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Lets me press j and k at the same time to escape insertion mode
Map('i', 'jk', '<Esc>')
Map('i', 'kj', '<Esc>')

-- Lets me use Alt + hjkl to move in insert and command mode
Map({'i', 'c', 't',}, '<A-h>', '<Left>')
Map({'i', 'c', 't',}, '<A-j>', '<Down>')
Map({'i', 'c', 't',}, '<A-k>', '<Up>')
Map({'i', 'c', 't',}, '<A-l>', '<Right>')

-- My remapings for moving far vertically and horizontally
Map('', 'H', '^')
Map('', 'L', '$')
Map('', 'K', '<C-u>zz')
Map('', 'J', '<C-d>zz')

-- Paste from register 0 instead of the unnamed register, such that we only paste what we yank
Map('', 'p', '"0p')
Map('', 'P', '"0gP') -- Moves the cursor after pasting with shift

-- Make x, only while in visual mode, cut text into register 0
Map('v', 'x', '"0x')

-- Use control to copy, cut, and paste from clipboard
Map('', '<C-p>', '"+p')
Map('', '<C-y>', '"+y')
Map('', '<C-x>', '"+x')

-- Use Control to paste while in insertion mode. p for default, v for clipboard
Map('i', '<C-p>', '<Esc>"0pa')
Map('i', '<C-v>', '<Esc>"+pa')

-- Intuitive tab indentation, only in visual mode
Map('v', '<TAB>', '>gv')
Map('v', '<S-TAB>', '<gv')

-- Lets me use cs (clear search) to stop highlighting search results
Map('n', 'cs', '<Cmd>noh<CR>')

-- Write buffers quickly
Map('', '<leader>w', '<Cmd>w<CR>')
Map('', '<leader>W', '<Cmd>wa<CR>')

-- Close a window quickly
Map('', '<leader>Q', '<Cmd>q<CR>')

-- Open and close the quickfix list easily
Map('', '<leader>ro', '<Cmd>copen<CR>')
Map('', '<leader>rq', '<Cmd>cclose<CR>')

-- Switch between windows quickly
Map({ 'n', 'v', 's', 'i', 't' }, '<C-h>', '<C-w>h')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-j>', '<C-w>j')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-k>', '<C-w>k')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-l>', '<C-w>l')

-- Resize windows quickly
Map({ 'n', 'v', 's', 'i', 't' }, '<C-Up>', '<Cmd>resize -2<CR>')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-Down>', '<Cmd>resize +2<CR>')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-Left>', '<Cmd>vertical resize -2<CR>')
Map({ 'n', 'v', 's', 'i', 't' }, '<C-Right>', '<Cmd>vertical resize +2<CR>')

-- Easier redo command
Map('', 'R', '<C-r>')

-- Toggle the header line
local function toggle_header()
	local current_tabline = vim.o.showtabline
	local next_tabline
	if current_tabline == 0 then
		next_tabline = 2
	else
		next_tabline = 0
	end

	vim.opt.showtabline = next_tabline
end
Map('', 'tk', toggle_header)

local function toggle_footer()
	local current_statusline = vim.o.laststatus
	local next_statusline
	if current_statusline == 0 then
		next_statusline = 2
	else
		next_statusline = 0
	end

	vim.opt.laststatus = next_statusline
end
Map('', 'tj', toggle_footer)

-- Just changing the vim option wouldn't be enough, it would not modify it in all the open buffers
-- So we need to change the option, then apply this change to all buffers
local function toggle_line_numbers()
	local original_buffer = vim.fn.bufnr()

	if vim.o.number then
		vim.opt.number = false
		vim.cmd('silent! bufdo set nonumber')
	else
		vim.opt.number = true
		vim.cmd('silent! bufdo set number')
	end

	vim.cmd('buffer ' .. original_buffer)


end
Map('', 'tl', toggle_line_numbers)

