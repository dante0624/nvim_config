return {
	{
		'williamboman/mason.nvim',
		tag = 'v1.8.0',
		dependencies = {
			'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			require('lsp') -- My folder, handles all setting up of all LSP stuff
		end,
	},
	{
		'williamboman/mason-lspconfig.nvim',
		tag = 'v1.17.1',
		lazy = true,
	},
	{
		'neovim/nvim-lspconfig',

		-- Latest tag breaks my configuration for some reason
		commit = '710d5386df1894ff5c84da48836e959b47294b5e',
		lazy = true,
	},
	{
		'hrsh7th/cmp-nvim-lsp',
		commit = '78924d1d677b29b3d1fe429864185341724ee5a2',
		lazy = true,
	},
	{
		'mfussenegger/nvim-jdtls',
		tag = '0.2.0',
		ft = "java",
	},
}
