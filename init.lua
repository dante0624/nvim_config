--[[ Super important file
Installs all the plugins, and requires them, and sets them up
Should be first for bootstrapping, because other files depend on plugins ]]
local packer_ready = require("myPlugins")
if not packer_ready then
	print("First use of packer, need to exit and re-enter. Then run :PackerSync to get plugins")
end

-- Use other lua files that I created
require("myKeymaps.vanillaNvim")
require("myFolding")
require("miscOptions")

-- Specifies my modificiations to a downloaded color scheme
local plugins_ready = require("myColors.nvimDarkTheme")
if packer_ready and not plugins_ready then
	print("Colorscheme, and likely other plugins missing. Run :PackerSync")
end

-- Give me the ability to quickly delete tmp folders and files
Flush = require("utils.flushTmp")
Clean_Buffers = require("utils.buffers").Clean_Empty

-- TODO:
-- September 1st, 2023

-- Some type of session manager so I can restore files quickly after running $ nvim with no arguments
	-- https://github.com/rmagatti/auto-session
	-- Looks like a very appealing solution

-- Look into root directory problem.
	-- Sometimes, nvimTree, telescope, and toggle term all get the root directory wrong
	-- They will pick some random subfolder (like a random test resource folder) and always make it that
	-- Persists between sessions
	-- May be fixed by simply cleaning out some cache file, tmp file
	-- Definitely fixed by uninstalling neovim, the editor and my config, then reinstalling

-- Find a way to quicky view all TODOs within a project
	-- Possibly all diagnostics, might be part of Trouble.nvim

-- Trouble.nvim
	-- Look into other things by Folke

-- Some type of session manager so I can restore files quickly after running $ nvim with no arguments
	-- https://github.com/rmagatti/auto-session
	-- Looks like a very appealing solution

-- Get undotree

-- Try out harpoon
	-- Alternative solution to a session manager
	-- Also try out the general workflow and see how it feels (not using nvim tree or buffer line)

-- Set new git icons for the file explorer
	-- Don't like the ones for new file and modified, I find them misleading

