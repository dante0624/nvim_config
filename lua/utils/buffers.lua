local M = {}

function M.Clean_Empty()
	for n=1,vim.fn.bufnr('$') do -- All buffers including hidden ones. ':ls!'
		local safe_to_delete =
			vim.fn.buflisted(n) == 1 and -- In the buffer list after typing ':ls'
			vim.fn.empty(vim.fn.bufname(n)) == 1 and -- Has no name
			vim.fn.bufwinnr(n) < 0 and -- Not in the current window
			vim.fn.getbufvar(n, '&mod') == 0 -- Hasn't been modified
		if safe_to_delete then
			vim.cmd('bd '..n)
		end
	end
end

return M

