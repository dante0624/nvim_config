local M = {}

--- Includes normal, visual, select, and operator pending modes.
--- This is the default in normal vim.
--- See `help map` and then `help map-modes`.
--- Commonly used for keymaps which start with "leader" or a command key.
M.default_key_map_modes = { "n", "x", "s", "o" }

--- Includes normal, visual, and operator pending modes.
--- Use these for any keymaps which are normal alpabetical characters
--- Preferable to exclude select mode, if the key is a normal a-zA-Z character
--- This is not needed for keymaps which start with "leader" or a command key,
--- As those can just the default "" keymapping mode, which is "nvo".
M.alpabetical_key_map_modes = { "n", "x", "o" }

--- Every single mode in neovim
--- See `help map` and then `help map-modes`.
M.all_key_map_modes = {"n", "i", "c", "x", "s", "o", "t", "l"}

--- Sets a global keymap.
---@param mode string|string[] Mode "short-name". Turns "" to "nvo".
--- See `help map` and then `help map-modes`.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping,
--- can be a Lua function.
---@param opts? vim.keymap.set.Opts Default is {noremap=true, silent=true}.
function M.map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

--- Sets a buffer local keymap.
---@param mode string|string[] Mode "short-name". Turns "" to "nvo".
--- See `help map` and then `help map-modes`
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping,
--- can be a Lua function.
---@param opts? vim.keymap.set.Opts Default is
--- {noremap=true, silent=true, buffer=0}.
function M.local_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, buffer = 0 }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

return M
