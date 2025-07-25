-- Things which should work with neovim, without needing any plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs
require("lsp.serverCommon").setup()

-- TODO:
--[[ Immediate planned steps:
Get a basic spellchecker with a dictionary of valid words.

Get Avante + MCP support and a free LLM.
	Either local DeepSeek or a free online LLM.

Put up a CR for my solution to TMUX OSC52 Paste.
	Will resolve any issues that I've commented on.
]]

--[[ Medium Priority Work:
Make certain keymaps apply to "visual" but not "select" mode.
	I've "C" for comment. Look for others.

Make the HUD work for all windows.
	Currently it works for all tabs, but not all windows.

Allow me to rename variables and files in a pop-out buffer.
	I want Visual, Insert, and Normal mode to work here.
	I'm surprised this isn't in neovim core tbh.
]]

--[[ Low Priority:
Remove auto-install of things. De-bloat.
	Remove auto-install of Language Servers and Dubuggers.
	Remove auto-install of Treesitter Parsers.
	Its easy to install these as-needed. Just put in the README.md file.
]]

