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

-- Simply moves the cursor after pasting with shift
Map('', 'P', 'gP')

-- Use control to copy, cut, and paste from clipboard
Map('', '<C-p>', '"+p')
Map('', '<C-y>', '"+y')
Map('', '<C-x>', '"+x')

-- Use Control to paste while in insertion mode. p for default, v for clipboard
Map('i', '<C-p>', '<Esc>pa')
Map('i', '<C-v>', '<Esc>"+pa')

-- Intuitive tabbing for me
Map('v', '<TAB>', '>gv')
Map('v', '<S-TAB>', '<gv')

-- Lets me use cs (clear search) to stop highlighting search results
Map('n', 'cs', '<Cmd>noh<CR>')

-- Slighly faster way of closing or reopening folds
Map('n', 'zz', 'za')

-- Toggle my tree (tt) plugin
Map('', 'tt', '<Cmd>NvimTreeToggle<CR>')

-- Switch between buffers quickly
Map('', '<leader><TAB>', '<Cmd>BufferLineCycleNext<CR>')
Map('', '<leader><S-TAB>', '<Cmd>BufferLineCyclePrev<CR>')
Map('', '<leader>q', '<Cmd>bd<CR>') -- bd is for buffer delete

-- Reorder my buffer tabs
Map('', '<leader>bl', '<Cmd>BufferLineMoveNext<CR>') -- Buffer Right (l)
Map('', '<leader>bh', '<Cmd>BufferLineMovePrev<CR>') -- Buffer Left (h)

-- Write and quit buffers quickly
Map('', '<leader>w', '<Cmd>w<CR>')
Map('', '<leader>W', '<Cmd>wa<CR>')
Map('', '<leader>Q', '<Cmd>q<CR>')


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

-- Telescope Opening
Map('', '<leader>f', '<Cmd>Telescope find_files<CR>')
Map('', '<leader>g', '<Cmd>Telescope live_grep<CR>')

