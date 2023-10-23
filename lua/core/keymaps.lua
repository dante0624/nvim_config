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
Map('', 'K', '020kzz')
Map('', 'J', '020jzz')

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

-- Removes the highlighting from the screen that comes with searching via "/"
Map('n', '<Leader>n', '<Cmd>noh<CR>')

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


