Terminal_Open_Mapping = [[<C-s>]] -- s for shell

function _G.set_terminal_keymaps()
	local function term_map(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true, buffer = 0,}
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end
		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- For some reason <C-\><C-n> has the effect of going from terminal mode to normal mode
	-- term_map('t', '<esc>', [[<C-\><C-n>]])
	term_map('t', 'jk', [[<C-\><C-n>]])
	term_map('t', 'kj', [[<C-\><C-n>]])
	term_map('t', '<C-h>', [[<Cmd>wincmd h<CR>]])
	term_map('t', '<C-j>', [[<Cmd>wincmd j<CR>]])
	term_map('t', '<C-k>', [[<Cmd>wincmd k<CR>]])
	term_map('t', '<C-l>', [[<Cmd>wincmd l<CR>]])
	-- term_map('t', '<C-w>', [[<C-\><C-n><C-w>]])

	--[[ My command to kill the terminal
	First <esc> just removes any text that may already be in the terminal.
	Then we type exit and hit enter to kill the terminal
		But this take a couple of seconds to actually kill the terminal.
		So then we go to normal mode, then do :q to exit the window.
	While the window is closed, the terminal is being killed in the background]]
	term_map('t', '<C-q>', [[<esc>exit<CR><C-\><C-n><Cmd>q<CR>]])
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

