-- Things which should work with neovim, without needing any plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs, Linters
require("lsp.serverCommon").setup()
require("linting.lintCommon").setup()
require("formatting.formatCommon").setup()

-- TODO:
--[[
NO CHANGES UNTIL SEPTEMBER 15th!!!

Make use of OSC 52 copy and paste
Modify linting to hava single file, with ignore and strict as table fields
	Rather than 2 file
Make LSP hover look pretty again (its not handling the markdown nicely right now)
Debug why telescope is sometimes delayed
Allow me to rename variables and files in a pop-out buffer.
	I want normal, insert, and visual mode to work in this pop-out buffer
	Enter makes the selection
]]

--[[ Python Plan
    Migrate to Based Pyright
        This will automatically give semantic highlighting
        In the future, it will hopefully support willRenameFiles LSP method

	Get conform and use ruff as a formatter
        Make <leader>af use conform if it is setup, but fallback on LSP
            Use <leader>p to format and save (p for "publish")
            Use <leader>P to format and save all

	Try out nvim/rope plugin
		If it works well, attempt filenames ]]

--[[ Refactoring Filenames plan
	Make it a custom command for neo-tree called refactor
		Unbind r for rename file
		Rebind it to r for refactor
	
	Have a refactoring method
		An LSP function that calls either willRenameFiles or didRenameFiles
		Needs to list if it should be applied before or after renaming
		Also list if the method supports directory refactoring or not
	
	Find the nearest LSP whose root is back far enough for the refactor

	Note about LSP refactoring method
		Copy how folke did it with Lazy again
		Double check the URI to see if it is a directory or not
	
	How the custom neotree command works
		Find the refactoring method based on LSP
		Apply refactor source before (if it specifies that)
		Rename the file
		Apply refactor source after (if it specifies that)

    Based Pyright Issue: https://github.com/DetachHead/basedpyright/issues/327
]]

--[[ Random Wants:
Get a basic spellchecker with a dictionary of valid words

Look into DAP, Linters, and Formatters
	Specifically configure for python

Look into unit testing with neotest
	Should be done after DAP is working ]]
