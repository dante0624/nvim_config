-- Things which should work with neovim itself, without needing any external plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs
require("lsp.languageCommon").setup()

-- TODO:
-- November 1st, 2023

-- Get https://github.com/iamcco/markdown-preview.nvim

-- Get a basic spellchecker with a dictionary of valid words

-- Look into DAP, Linters, and Formatters
	-- Especially python ones as they may be useful at work

-- Find a way to quicky view all diagnostics and TODOs within a project
	-- Possibly Trouble.nvim

-- Get undotree

