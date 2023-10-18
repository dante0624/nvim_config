return {{
	'nvim-lualine/lualine.nvim',
	tag = "compat-nvim-0.6",
	dependencies = { 'nvim-tree/nvim-web-devicons', },
	lazy = false, -- Don't lazy load, for my session management
	opts = {
		sections = {
			lualine_a = {'mode'},
			lualine_b = {
				{'branch', color='ColorColumn', },
				{'diff', color='ColorColumn'},
			},
			lualine_c = {
				{'filename', color='Normal'}
			},
			lualine_x = {
				{'fileformat', color='Normal'},
				{'filetype', color='Normal'}
			},
			lualine_y = {
				{'progress', color='ColorColumn'},
				{'location', color='ColorColumn'}
			},
			lualine_z = {
				{'datetime', style="%H:%M", color='Cursor'}
			},
		},
	},
}}

