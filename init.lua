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
--[[ Small things that are bugging me:
Revert usage of OSC 52 copy and paste.
	Look into x-clip for SSH.

Add LSP Startup messages for all LSPs
	Only needed for Java but nice for everything.

Make the HUD work for all windows.
	Currently it works for all tabs, but not all windows.

Modify linting to hava single file.
	Ignore and strict as table fields, rather than 2 file.

Make LSP hover look pretty.
	Its not handling the markdown nicely right now.

Allow me to rename variables and files in a pop-out buffer.
	I want Visual, Insert, and Normal mode to work here.
]]


--[[ Java LSP Issues:
Some issue with a file lock
	Logs can be found under ~/.local/share/nvim/Java_Workspaces/<Specific-Workspace>/.metadata/.log
		It talks about waiting for a lock

	File table lock is at ~/.local/share/nvim/mason/packages/jdtls/config_<OS>/org.eclipse.osgi/.manager/.fileTableLock
		For some reason, deleting this file (even though it is empty) fixes the problem

	This bug happens "late". After the LSP already starts up, and the buffers say that are attached to the LSP.


Changing dependencies or git branches SOMETIMES (need to reproduce reliably), causes the LSP to fail on startup.
]]

--[[ Random Wants:
Get a basic spellchecker with a dictionary of valid words

Look into DAP, Linters, and Formatters
	Specifically configure for python

Look into unit testing with neotest
	Should be done after DAP is working ]]
