local M = {}

function M.map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Sets a keymap to only the current buffer
-- Unused function right now, but it may be useful later
function M.local_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, buffer = 0, }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Lazy.nvim defaults to mode="n", but I like mode={"n", "v"}
-- It also wants all keymaps to exist in a table structure
function M.lazy_map(all_map_tbls)
	for _, map_tbl in ipairs(all_map_tbls) do
		if map_tbl.mode == nil then
			map_tbl.mode = {"n", "v"}
		end
	end

	return all_map_tbls
end

return M

