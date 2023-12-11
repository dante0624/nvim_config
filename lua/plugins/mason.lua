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
				"lua_ls", -- Lua LSP
				"pyright", -- Python LSP
				"jdtls", -- Java LSP
				"tsserver", -- Typescript and Javascript LSP
				"html", -- HTML LSP
				"cssls", -- CSS LSP
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
			-- This version locks all LSPs, Linters, Formatters, and DAPs
			registries = {
				"github:mason-org/mason-registry@2023-10-23-stormy-end",
			},
		},
	},
	-- Not actually a mason related plugin
	-- This just helps run jdtls, so it fits nicely here
	{
		'mfussenegger/nvim-jdtls',
		tag = '0.2.0',
		ft = "java",
	},
}
