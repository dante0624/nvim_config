local Map = require("utils.map").Map

local left_tab = '<Cmd>BufferLineCyclePrev<CR>'
local right_tab = '<Cmd>BufferLineCycleNext<CR>'

-- Manipulate Buffer Tabs
Map('n', '<TAB>', right_tab)
Map('n', '<S-TAB>', left_tab)
Map('', '<leader><TAB>', '<Cmd>BufferLineMoveNext<CR>')
Map('', '<leader><S-TAB>', '<Cmd>BufferLineMovePrev<CR>')

-- Drop current buffer, and move left after doing so
-- Default behavior is to go to the last visited buffer, so this is a hack which uses that fact
Map('', '<leader>q', left_tab .. right_tab .. '<Cmd>bd<CR>')

-- Pick buffer to immediately jump to or drop
Map('', 'tp', '<Cmd>BufferLinePick<CR>')
Map('', 'td', '<Cmd>BufferLinePickClose<CR>')

