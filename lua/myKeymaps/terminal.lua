Terminal_Open_Mapping = "<Leader>t"

function _G.set_terminal_keymaps()
	local function term_map(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true, buffer = 0,}
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end
		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- For some reason <C-\><C-n> has the effect of going from terminal mode to normal mode
	-- The intention here is to exit the terminal with <j & k>, q
	term_map('t', 'jk', [[<C-\><C-n>]])
	term_map('t', 'kj', [[<C-\><C-n>]])
	term_map({'n', 'v'}, 'q', '<CMD>ToggleTerm<CR>')
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

