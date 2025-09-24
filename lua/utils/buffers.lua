local M = {}

--- Gets the buffers ids which are listed, excluding the [No Name] buffer
---@return integer[]
function M.get_listed_user_buffer_ids()
	local is_user_buffer_filter = function(buf)
		return vim.fn.buflisted(buf) == 1 and
			vim.fn.empty(vim.fn.bufname(buf)) ~= 1
	end

	return M.get_buffer_ids(is_user_buffer_filter)
end

--- Get a list of buffer ids which pass some filter
---@param filter? fun(buf: integer):boolean
---@return integer[]
function M.get_buffer_ids(filter)
	local buffer_ids = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if (filter == nil or filter(buf)) then
			table.insert(buffer_ids, buf)
		end
	end

	return buffer_ids
end

function M.clean_no_name_buffers()
	-- Loop over all buffers, including hidden ones. Like ':ls!'
	for _, n in ipairs(vim.api.nvim_list_bufs()) do
        -- Check if the buffer is safe to delete
		if vim.fn.empty(vim.fn.bufname(n)) == 1 and -- Has no name
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
