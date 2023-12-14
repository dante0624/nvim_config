return {
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
				"github:mason-org/mason-registry@2023-12-13-smug-hamlet",
			},
		},
	},
	{
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		dependencies = {
			'williamboman/mason.nvim',
		},
		commit = '8b70e7f1e0a4119c1234c3bde4a01c241cabcc74',
		lazy = false,
		opts = {
			ensure_installed = {
				"lua-language-server", -- Lua LSP
				"pyright", -- Python LSP
				"jdtls", -- Java LSP
				"typescript-language-server", -- Typescript and Javascript LSP
				"html-lsp", -- HTML LSP
				"css-lsp", -- CSS LSP
			},
		},
	},
	-- This just helps run jdtls, so it fits nicely here
	{
		'mfussenegger/nvim-jdtls',
		tag = '0.2.0',
		ft = "java",
	},
}
