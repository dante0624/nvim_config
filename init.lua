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

	Try out nvim/rope plugin
		-- If it works well, attempt filenames

	Make keymap which toggles "strictness"
		-- Basically disable flake8 and pydocstyle lintings
		-- Not sure how exactly, probably have two different lint configs
			-- A strict one and a lenient one

		-- Probably start under ftplugin/python, then move to HUD
		-- HUD keymap will probably be leader-h-s

--[[ Refactoring Filenames plan
	Make it a custom command for neo-tree called refactor
		Unbind r for rename file
		Rebind it to r for refactor
	
	Have several refactoring sources
		An LSP function that calls either willRenameFiles or didRenameFiles
		An external plugin, etc
		Needs to list if it should be applied before or after renaming
	
	Have a single file that maps a file extension to its source
		Source can be an external plugin (like rope)
		Source can be an LSP with a specific name
	
	How the LSP function works
		Loop through all clients
		Skip those whose root_dir isn't back far enough or name is wrong
		Make the server request to all remaining

		Also double check the file URI for files vs directories
		See which LSPs support file vs directory refactor

	How the custom command works
		Checks the refactor source based on file extension
		Apply refactor source before (if it specifies that)
		Rename the file
		Apply refactor source after (if it specifies that)
]]

-- Get https://github.com/iamcco/markdown-preview.nvim
-- Also get the VSCode Markdown lsp

-- Get a basic spellchecker with a dictionary of valid words

-- Look into DAP, Linters, and Formatters
-- Especially python ones as they may be useful at work

-- Find a way to quicky view all diagnostics and TODOs within a project
-- Possibly Trouble.nvim

-- Get undotree
