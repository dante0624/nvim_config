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
require("myKeymaps.toggleHUD")

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

-- Update Flush module
	-- Add ability to flush prior sessions
	-- Implement Flush.All() function

-- Update Package Manager
	-- Set commit hashes for each plugin, this way things don't randomly break without me knowing
	-- Maybe one day go to lazy.nvim but probably not soon

-- Find a way to quicky view all TODOs within a project
	-- Possibly all diagnostics, might be part of Trouble.nvim

-- Get undotree

