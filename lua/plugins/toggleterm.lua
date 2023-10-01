local open_mapping = 'tt'

function _G.set_term_keymaps()
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

return {{
	'akinsho/toggleterm.nvim',
	tag = "v2.8.0",
	keys = {
		{open_mapping, '<CMD>ToggleTerm<CR>', mode={'n', 'v',}},
		{
			'<Leader><CR>',
			function()
				local toggleterm = require("toggleterm")
				local run_command = vim.b.run_command
				if run_command ~= nil then
					toggleterm.exec(run_command)
				end
			end,
			mode={'n', 'v',}
		},
	},
	config = function()
		require("utils.shell").set_shell()

		vim.cmd('autocmd! TermOpen term://* lua set_term_keymaps()')

		require("toggleterm").setup({
			direction = 'float',
			size = 20, -- Only relevant if I switch to horizontal
			shade_terminals = false,
			open_mapping = open_mapping,
			insert_mappings = false, -- whether or not the open mapping applies in insert mode
			terminal_mappings = false, -- whether or not the open mapping applies in terminal mode
			persist_mode = false,
			float_opts = {
				width = function() return math.floor(vim.o.columns * 0.9) end,
				height = function() return math.floor(vim.o.lines * 0.9) end,
			}
		})
	end,
}}

