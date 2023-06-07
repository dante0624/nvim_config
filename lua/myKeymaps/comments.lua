local Map = require("utils.map").Map

local api = require('Comment.api')
Map('n', 'C', api.toggle.linewise.current)
Map('v', 'C', '<Plug>(comment_toggle_linewise_visual)gv')

Map('n', '<leader>cl', api.toggle.blockwise.current)
Map('v', '<leader>cl', '<Plug>(comment_toggle_blockwise_visual)gv')

Map('n', '<leader>cO', api.insert.linewise.above)
Map('n', '<leader>co', api.insert.linewise.below)
Map('n', '<leader>cA', api.insert.linewise.eol)

