--[[ Super important file
Installs all the plugins, and requires them, and sets them up
Should be first for bootstrapping, because other files depend on plugins ]]
local packer_ready = require("myPlugins")
if not packer_ready then
	print("First use of packer, need to exit and re-enter. Then run :PackerSync to get plugins")
end

-- Things which should work with neovim itself, without needing any external plugins
-- Includes basic keymaps, options, and mini modules which I made myself (filenames begin with "my")
require("core")

-- Specifies my modificiations to a downloaded color scheme
-- TODO: Move this to the configuration of the colorscheme plugin itself
local plugins_ready = require("myColors.nvimDarkTheme")
if packer_ready and not plugins_ready then
	print("Colorscheme, and likely other plugins missing. Run :PackerSync")
end

-- TODO:
-- September 1st, 2023

-- Update Package Manager
	-- Set commit hashes for each plugin, this way things don't randomly break without me knowing
	-- Maybe one day go to lazy.nvim but probably not soon

-- Find a way to quicky view all TODOs within a project
	-- Possibly all diagnostics, might be part of Trouble.nvim

-- Get undotree

