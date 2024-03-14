local M = {}

function M.get_full_text(bufnr)
	local format_line_ending = {
	  ['unix'] = '\n',
	  ['dos'] = '\r\n',
	  ['mac'] = '\r',
	}

	local line_ending = format_line_ending[
		vim.api.nvim_buf_get_option(bufnr, 'fileformat')
	] or '\n'

	local text = table.concat(
		vim.api.nvim_buf_get_lines(bufnr, 0, -1, true),
		line_ending
	)

	if vim.api.nvim_buf_get_option(bufnr, 'eol') then
		text = text .. line_ending
	end
	return text
end

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

return M
