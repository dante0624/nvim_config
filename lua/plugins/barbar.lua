local map = require("utils.map").map

return {{
	'romgrk/barbar.nvim',
	tag = "v1.7.0",
	dependencies = {
		'nvim-tree/nvim-web-devicons',
		'lewis6991/gitsigns.nvim',
	},
	lazy = false, -- Don't lazy load, for my session management
	config = function()
		require('barbar').setup({
			animation = false,
			insert_at_end = true,
			focus_on_close = 'left',
			no_name_title = '[No Name]',
		})

		-- Manipulate Buffer Tabs
		map('n', '<S-TAB>', '<Cmd>BufferPrev<CR>')
		map('n', '<TAB>', '<Cmd>BufferNext<CR>')
		map('', '<leader><S-TAB>', '<Cmd>BufferMovePrev<CR>')
		map('', '<leader><TAB>', '<Cmd>BufferMoveNext<CR>')

		map('', '<leader>q', '<Cmd>BufferClose<CR>')

		-- Pick buffer to immediately jump to a buffer
		map('', '<C-a>', '<Cmd>BufferGoto 1<CR>')
		map('', '<C-s>', '<Cmd>BufferGoto 2<CR>')
		map('', '<C-d>', '<Cmd>BufferGoto 3<CR>')
		map('', '<C-f>', '<Cmd>BufferGoto 4<CR>')
		map('', '<C-g>', '<Cmd>BufferGoto 5<CR>')

	end,
}}

