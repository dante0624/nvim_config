local Map = require("utils.map").Map

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
		Map('n', '<S-TAB>', '<Cmd>BufferPrev<CR>')
		Map('n', '<TAB>', '<Cmd>BufferNext<CR>')
		Map('', '<leader><S-TAB>', '<Cmd>BufferMovePrev<CR>')
		Map('', '<leader><TAB>', '<Cmd>BufferMoveNext<CR>')

		Map('', '<leader>q', '<Cmd>BufferClose<CR>')

		-- Pick buffer to immediately jump to a buffer
		Map('', '<C-a>', '<Cmd>BufferGoto 1<CR>')
		Map('', '<C-s>', '<Cmd>BufferGoto 2<CR>')
		Map('', '<C-d>', '<Cmd>BufferGoto 3<CR>')
		Map('', '<C-f>', '<Cmd>BufferGoto 4<CR>')
		Map('', '<C-g>', '<Cmd>BufferGoto 5<CR>')

	end,
}}

