-- Things which should work with neovim itself, without needing any external plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- TODO:
-- November 1st, 2023

-- Move all LSP setup calls to ftplugin/*
	-- Rename handlers to commonLSP or something
	-- Each file type can import the on_attach function from here, and use it
	-- Lazy's profiling tool shows Mason takes 14.5 ms to startup, try to decrease
		-- Good idea, this way when we add more languages, the startup time is not affeected

-- Get https://github.com/iamcco/markdown-preview.nvim

-- Get a basic spellchecker with a dictionary of valid words

-- Look into DAP, Linters, and Formatters
	-- Especially python ones as they may be useful at work

-- Find a way to quicky view all diagnostics and TODOs within a project
	-- Possibly Trouble.nvim

-- Get undotree

