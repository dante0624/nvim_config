return {{
	'williamboman/mason-lspconfig.nvim',
	dependencies = {
		'neovim/nvim-lspconfig',
		'williamboman/mason.nvim',
		'hrsh7th/cmp-nvim-lsp',

		-- Configure Java Lsp differently because it wants to be hard
		-- Actual configuration is found under ftplugin/java.lua
		'mfussenegger/nvim-jdtls',
	},
    event = { "BufReadPre", "BufNewFile" },
	config = function()
		require('lsp') -- My folder, handles all setting up of all LSP stuff
	end,
}}
