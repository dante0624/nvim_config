--[[ TODO:Create my own wrapper around Mason and Treesitter called Carpenter
	Implement this if I use a remote server, and don't want to install all
		Lsps, Linters, Formatters, etc for every single language
	
	This should allow me to install everything I need on a per-language basis
	Also should have a built in check function to see if something is installed
	and an uninstall function

	Call this check function in several places:
		Treesitter folding:
			If the parser doesn't exist, use "syntax" rather than "expr"
		LSP:
			If the LSP doens't exist, skip it in start_or_attach
		Linter:
			If the linter doesn't exist, skip it in setup_linters
		More to come likely
	
	Implement Carpenter by deconstructing how mason-tool-installer works
		Then remove this plugin
		Then make mason lazy loaded ]]
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
