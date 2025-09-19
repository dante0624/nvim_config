local M = {}

function M.clean_empty()
	for n=1,vim.fn.bufnr('$') do -- All buffers including hidden ones. ':ls!'

        -- Check if the buffer is safe to delete
		if vim.fn.buflisted(n) == 1 and -- In the buffer list after typing ':ls'
			vim.fn.empty(vim.fn.bufname(n)) == 1 and -- Has no name
			vim.fn.bufwinnr(n) < 0 and -- Not in the current window
			vim.fn.getbufvar(n, '&mod') == 0 -- Hasn't been modified
        then
			vim.cmd('bd '..n)
		end
	end
end

-- Create a buffer with the given name, and return its buffer number
-- If the name is already in use, make it listed and return its existing buffer number
function M.create_buffer(name)
	local existing_buffer_number = vim.fn.bufnr(name)
	if existing_buffer_number ~= -1 then
		vim.bo[existing_buffer_number].buflisted = true
		return existing_buffer_number
	end

	local new_buffer_number = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(new_buffer_number, name)
	return new_buffer_number
end

return M
