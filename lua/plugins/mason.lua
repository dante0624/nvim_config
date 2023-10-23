return {
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = {
			'williamboman/mason.nvim',
		},
		tag = 'v1.17.1',
		lazy = false,
		opts = {
			ensure_installed = {
				"lua_ls", -- Lua
				"pyright", -- Python
				"jdtls", -- Java
				"tsserver", -- Typescript and Javascript
				"html", -- HTML
				"cssls", -- CSS
			},
		},
	},
	{
		'williamboman/mason.nvim',
		tag = 'v1.8.0',
		lazy = false,
		opts = {
			install_root_dir = require("utils.directories").Mason_Dir,
			PATH = "skip",
			ui = {
				width = 0.9,
				height = 0.9,
				keymaps = {
					toggle_help = "?",
				},
			},
			registries = {
				"github:mason-org/mason-registry@2023-10-23-stormy-end",
			},
		},
	},
	{
		'mfussenegger/nvim-jdtls',
		tag = '0.2.0',
		ft = "java",
	},
}
