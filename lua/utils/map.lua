local M = {}

function M.Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Sets a keymap to only the current buffer
-- Unused function right now, but it may be useful later
function M.Local_Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, buffer = 0, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

return M

