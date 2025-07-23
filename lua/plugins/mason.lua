return {
	{
		"williamboman/mason.nvim",
		tag = "v1.11.0",
		lazy = false,
		opts = {
			install_root_dir = require("utils.paths").Mason_Path,
			PATH = "skip",
			ui = {
				width = 0.9,
				height = 0.9,
				keymaps = {
					toggle_help = "?",
				},
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		commit = "1255518cb067e038a4755f5cb3e980f79b6ab89c",
		lazy = false,
		opts = {
			ensure_installed = {
				-- LSPs
				"html-lsp", -- HTML
				"css-lsp", -- CSS
				"typescript-language-server", -- JS and TS
				"lua-language-server", -- Lua
				"pyright", -- Python
				"jdtls", -- Java

				-- Debuggers (DAPs)
				"java-debug-adapter",

				-- Linters
				"htmlhint", -- HTML

				-- Formatters
				"prettierd", -- HTML, CSS, JS, TS, JSON, and Markdown
				"stylua", -- Lua

				-- Things that are both Linters and Formatters
				"stylelint", -- CSS
			},
		},
	},
}
