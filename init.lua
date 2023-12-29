-- Things which should work with neovim, without needing any plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs, Linters
require("lsp.languageCommon").setup()
require("linting.lintCommon").setup()

-- TODO:
--[[ Python Plan
	Get conform and use ruff as a formatter
		-- Keybinds should be <leader>ro and <leader>ra
		-- Reformat and refactor 
			-- Conform should apply both ruff reformats (format and fix)
			-- Refactoring should only applies to nvim/rope
			-- If other languages have non-lsp refactoring, also use <leader>ra
		-- Then map <leader>p to reformat and then save
		-- <leader>P should do it to all buffers

	Try out nvim/rope plugin
		-- If it works well, attempt filenames

--[[ Refactoring Filenames plan
	Make it a custom command for neo-tree called refactor
		Unbind r for rename file
		Rebind it to r for refactor
	
	Have several refactoring method
		An LSP function that calls either willRenameFiles or didRenameFiles
		An external plugin, etc
		Needs to list if it should be applied before or after renaming
		Also list if the method supports directory refactoring or not
	
	Find the nearest LSP whose root is back far enough for the refactor
		Have a file which maps LSPs to the refactoring method

	Note about LSP refactoring method
		Copy how folke did it with Lazy again
		Double check the URI to see if it is a directory or not
	
	How the custom neotree command works
		Find the refactoring method based on LSP
		Apply refactor source before (if it specifies that)
		Rename the file
		Apply refactor source after (if it specifies that)
]]

-- Get a plugin for viewing marks
	-- Then toggle the marks on the HUD with <leader>hm

-- Get https://github.com/iamcco/markdown-preview.nvim
-- Also get the VSCode Markdown lsp

-- Get a basic spellchecker with a dictionary of valid words

-- Look into DAP, Linters, and Formatters
	-- Specifically configure for python

-- Look into unit testing with neotest
	-- Should be done after DAP is working

-- Find a way to quicky view all diagnostics within a project
	-- Possibly Trouble.nvim
