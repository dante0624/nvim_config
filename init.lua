-- Things which should work with neovim itself, without needing any external plugins
-- Includes basic keymaps, options, and mini modules which I made myself (filenames begin with "my")
require("core")
require("lazyLauncher")

-- Specifies my modificiations to a downloaded color scheme
-- TODO: Move this to the configuration of the colorscheme plugin itself
local plugins_ready = require("myColors.nvimDarkTheme")

-- TODO:
-- September 1st, 2023

-- Update Package Manager
	-- Maybe one day go to lazy.nvim but probably not soon
	-- Remove NullLS and see if we can still have html and css lsps
	-- Set commit hashes for each plugin, this way things don't randomly break without me knowing

-- Find a way to quicky view all TODOs within a project
	-- Possibly all diagnostics, might be part of Trouble.nvim

-- Get undotree

