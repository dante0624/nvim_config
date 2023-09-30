return {
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {},
	},
	{
		'windwp/nvim-ts-autotag',
		event = "InsertEnter",
		-- Treesitter is also responsible for config / setup of this plugin
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
	},
	{
		'numToStr/Comment.nvim',
		opts = {},
		keys = {
			{'C', function() require('Comment.api').toggle.linewise.current() end, mode = 'n'},
			{'C', '<Plug>(comment_toggle_linewise_visual)gv', mode = 'v'},

			{'<leader>cl', function() require('Comment.api').toggle.blockwise.current() end, mode = 'n'},
			{'<leader>cl', '<Plug>(comment_toggle_blockwise_visual)gv', mode = 'v', },

			{'<leader>cO', function() require('Comment.api').insert.linewise.above() end, mode = 'n'},
			{'<leader>co', function() require('Comment.api').insert.linewise.below() end, mode = 'n'},
			{'<leader>cA', function() require('Comment.api').insert.linewise.eol() end, mode = 'n'},
		},
	},
}

