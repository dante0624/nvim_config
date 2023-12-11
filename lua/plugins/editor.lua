return {
	{
		-- This author doesn't seem to use tags, so use the commits instead
		'windwp/nvim-autopairs',
		commit = "de4f7138a68d5d5063170f2182fd27faf06b0b54",
		event = "InsertEnter",
		opts = {},
	},
	{
		'windwp/nvim-ts-autotag',
		commit = "6be1192965df35f94b8ea6d323354f7dc7a557e4",
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		event = "InsertEnter",
		config = function()
			require('nvim-treesitter.configs').setup({
				autotag = {
					enable = true,
					enable_rename = false,
					enable_close = true,
					enable_close_on_slash = true,
					filetypes = { "html", "xml" },
				},
			})
		end,

	},
	{
		'numToStr/Comment.nvim',
		tag = "v0.8.0",
		opts = {},
		keys = {
			{'C', function()
				require('Comment.api').toggle.linewise.current()
			end, mode = 'n'},
			{'C',
				'<Plug>(comment_toggle_linewise_visual)gv',
			mode = 'v'},

			-- "cm" is supposed to be short for "comment multi-line"
			{'<leader>cm', function()
				require('Comment.api').toggle.blockwise.current()
			end, mode = 'n'},
			{'<leader>cm',
				'<Plug>(comment_toggle_blockwise_visual)gv',
			mode = 'v', },

			{'<leader>ck', function()
				require('Comment.api').insert.linewise.above()
			end, mode = 'n'},
			{'<leader>cj', function()
				require('Comment.api').insert.linewise.below()
			end, mode = 'n'},
			{'<leader>cl', function()
				require('Comment.api').insert.linewise.eol()
			end, mode = 'n'},
		},
	},
}

