-- Things which should work with neovim, without needing any plugins
-- Includes basic keymaps, options, and mini modules which I made myself
require("core")

-- Launches lazy.nvim, which then sets up and manages all plugins
require("lazyLauncher")

-- Sets up things which are common to all LSPs
require("lsp.serverCommon").setup()

-- TODO:
--[[ Immediate planned steps:
Do remote work in Neovim similar to how Neovide does it:
  1. First, start up neovim with a client / server split:
    - https://neovide.dev/features.html#unix-domain-socket-example
  2. For any clipboard copy-paste, the server makes a specific RPC request 
    ```
    vim.rpcrequest(some_channel_id, 'custom.set_clipboard', lines)
	vim.rpcrequest(some_channel_id, 'custom.get_clipboard')
	````
  3. Handle this request on the client side. Couple of ways this can go:
    a. Make a wrapper script around the server-client initialization.
	  It should setup a second client, whose only job is to wrap the clipboard.
	  Then the server makes its rpc requests to only that client
	b. Make the local neovim client code (all C) handle these RPC requests.
	  This would involve forking neovim, modifying, then building from source.

Get Avante + MCP support and a free LLM.
	Either local LLM from Ollama  or a free-tier of an online LLM.
]]

--[[ Medium Priority Work:
Allow me to rename variables and files in a pop-out buffer.
	I want Visual, Insert, and Normal mode to work here.
	I'm surprised this isn't in neovim core tbh.
]]

--[[ Low Priority:
Remove auto-install of things. De-bloat.
	Remove auto-install of Language Servers and Debuggers.
	Remove auto-install of Treesitter Parsers.
	Its easy to install these as-needed. Just put in the README.md file.
]]

