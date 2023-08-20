local Map = require("utils.map").Map

-- Manipulate Buffer Tabs
Map('n', '<TAB>', '<Cmd>BufferLineCycleNext<CR>')
Map('n', '<S-TAB>', '<Cmd>BufferLineCyclePrev<CR>')
Map('', '<leader><TAB>', '<Cmd>BufferLineMoveNext<CR>')
Map('', '<leader><S-TAB>', '<Cmd>BufferLineMovePrev<CR>')

