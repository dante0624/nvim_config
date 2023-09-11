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

-- Add ability to immediately jump to open buffer
	-- To make this work, we need a guarantee that new buffers will be added all the way to the right always
		-- This doesn't happen if a buffer was previously in the middle, then we drop it and re-add it.
		-- In this case it will go to where it used to be
	-- Also look into issue related to the buffer line being toggled off
		-- Issue happens if we start with one file, turn off buffer line, and telescope to a new file. Then bufffer cycling does not work.
		-- It begins to work if we quickly toggle the buffer line on and off again. No idea why.
	-- Vim shortcuts should be Control a-g

-- Some type of session manager so I can restore files quickly after running $nvim with no arguments
	-- https://github.com/rmagatti/auto-session
		-- Looks like a very appealing solution
	-- Should remember everything that was toggled, and restore views (the folds)
	-- Need to restore the bufferline at the top exactly as it was (same order)

-- Update Flush module
	-- Add ability to flush prior sessions
	-- Implement Flush.All() function

-- Update Package Manager
	-- Set commit hashes for each plugin, this way things don't randomly break without me knowing
	-- Maybe one day go to lazy.nvim but probably not soon

-- Find a way to quicky view all TODOs within a project
	-- Possibly all diagnostics, might be part of Trouble.nvim

-- Get undotree

