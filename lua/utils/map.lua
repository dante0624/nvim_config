local M = {}

function M.map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Sets a keymap to only the current buffer
-- Unused function right now, but it may be useful later
function M.local_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true, buffer = 0 }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Lazy.nvim defaults to mode="n", but I like mode={"n", "v"}
-- See https://lazy.folke.io/spec/lazy_loading#%EF%B8%8F-lazy-key-mappings
-- This explains the table spec
function M.lazy_map(all_lazy_key_mappings)
	for _, lazy_key_mappings in ipairs(all_lazy_key_mappings) do
		if lazy_key_mappings.mode == nil then
			lazy_key_mappings.mode = { "n", "v" }
		end
	end

	return all_lazy_key_mappings
end

return M
