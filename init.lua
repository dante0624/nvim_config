-- Use other lua files that I created
require("myKeymaps.vanillaNvim")
require("myFolding")
require("misc_options")

-- Specifies my modificiations to a downloaded color scheme
require("myColors.nvimDarkTheme")

-- Super important file
-- Installs all the plugins, and requires then and sets them up
require("myPlugins")

-- Give me the ability to quickly delete tmp folders and files
Flush = require("utils.flush_tmp")

-- TODO:
-- Trouble.nvim
	-- And other things by Folke
-- Get undotree

-- Learn more about using GIT in file explorer.
	-- Learn and remap some keybinds

