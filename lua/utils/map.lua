local M = {}

function M.Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Sets a keymap to only the current buffer
function M.Local_Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, }

	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	local mode_table
	if type(mode) == "string" then
		mode_table = { mode }
	elseif type(mode) == "table" then
		mode_table = mode
	end

	-- The built in function here only allows a single node as a string
	-- So my function allos tables or strings, then calls in a loop
	for _, mode_str in pairs(mode_table) do
		vim.api.nvim_buf_set_keymap(0, mode_str, lhs, rhs, options)
	end
end

return M

