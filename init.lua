-- Things which should work with neovim, without needing any plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs, Linters
require("lsp.languageCommon").setup()
require("linting.lintCommon").setup()

-- TODO:
-- November 1st, 2023

-- Get https://github.com/iamcco/markdown-preview.nvim
	-- Also get the VSCode Markdown lsp

-- Get a basic spellchecker with a dictionary of valid words

-- Look into DAP, Linters, and Formatters
	-- Especially python ones as they may be useful at work

-- Find a way to quicky view all diagnostics and TODOs within a project
	-- Possibly Trouble.nvim

-- See if NeoTree or OIL can allow you to refactor filenames and location
	-- Critically, it should update import statements automatically
	-- Needs to hook into an LSP which supports this feature
	-- Seems amazing for refactoring

-- Get undotree

