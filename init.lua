--[[ Super important file
Installs all the plugins, and requires them, and sets them up
Should be first for bootstrapping, because other files depend on plugins ]]
local plugins_ready = require("myPlugins")
if not plugins_ready then
	print("First use of packer, need to exit and re-enter for plugins")
end

-- Use other lua files that I created
require("myKeymaps.vanillaNvim")
require("myFolding")
require("miscOptions")

-- Specifies my modificiations to a downloaded color scheme
if plugins_ready then
	require("myColors.nvimDarkTheme")
end

-- Give me the ability to quickly delete tmp folders and files
Flush = require("utils.flushTmp")

-- TODO:
-- Find a way to quicky view all TODOs within a project

-- Trouble.nvim
	-- And other things by Folke
-- Get undotree

-- Learn more about using GIT in file explorer.
	-- Learn and remap some keybinds

