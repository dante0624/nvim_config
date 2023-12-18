local map = require("utils.map").map

-- Maps leader to the spacebar (pretty universal)
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Lets me press j and k at the same time to escape insertion mode
map('i', 'jk', '<Esc>')
map('i', 'kj', '<Esc>')

-- Lets me use Alt + hjkl to move in insert and command mode
map({'i', 'c', 't',}, '<A-h>', '<Left>')
map({'i', 'c', 't',}, '<A-j>', '<Down>')
map({'i', 'c', 't',}, '<A-k>', '<Up>')
map({'i', 'c', 't',}, '<A-l>', '<Right>')

-- My remapings for moving far vertically and horizontally
map('', 'H', '^')
map('', 'L', '$')
map('', 'K', '020kzz')
map('', 'J', '020jzz')

-- Only paste what we "yank", not the deleted text
map('', 'p', '"0p')
map('', 'P', '"0gP') -- Moves the cursor after pasting with shift

-- Make x, only while in visual mode, cut text into register 0
map('v', 'x', '"0x')

-- Use control to copy, cut, and paste from clipboard
map('', '<C-p>', '"+p')
map('', '<C-y>', '"+y')
map('', '<C-x>', '"+x')

-- Use Control to paste while in insertion mode.
-- p for default, v for clipboard
map('i', '<C-p>', '<Esc>"0pa')
map('i', '<C-v>', '<Esc>"+pa')

-- Intuitive tab indentation, only in visual mode
map('v', '<TAB>', '>gv')
map('v', '<S-TAB>', '<gv')

-- Removes the highlighting from the screen that comes with searching via "/"
map('n', '<Leader>n', '<Cmd>noh<CR>')

-- Write buffers quickly
map('', '<leader>w', '<Cmd>w<CR>')
map('', '<leader>W', '<Cmd>wa<CR>')

-- Close a window quickly
map('', '<leader>q', '<Cmd>q<CR>')
map('', '<leader>Q', '<Cmd>q!<CR>')

-- Open and close the quickfix list easily
map('', 'go', '<Cmd>copen<CR>')
map('', 'gq', '<Cmd>cclose<CR>')

-- Switch between windows quickly
map({ 'n', 'v', 's', 'i', 't' }, '<C-h>', '<C-w>h')
map({ 'n', 'v', 's', 'i', 't' }, '<C-j>', '<C-w>j')
map({ 'n', 'v', 's', 'i', 't' }, '<C-k>', '<C-w>k')
map({ 'n', 'v', 's', 'i', 't' }, '<C-l>', '<C-w>l')

-- Resize windows quickly
map({ 'n', 'v', 's', 'i', 't' }, '<C-Up>', '<Cmd>resize -2<CR>')
map({ 'n', 'v', 's', 'i', 't' }, '<C-Down>', '<Cmd>resize +2<CR>')
map({ 'n', 'v', 's', 'i', 't' }, '<C-Left>', '<Cmd>vertical resize -2<CR>')
map({ 'n', 'v', 's', 'i', 't' }, '<C-Right>', '<Cmd>vertical resize +2<CR>')

-- Easier redo command
map('', 'R', '<C-r>')

-- Within a plugin I like to remap Control-A for Tab Selection
-- So use Leader-A for this behavior
-- When hovered over a number, it will cause this number to be incremented
map('', '<leader>a', '<C-a>')
