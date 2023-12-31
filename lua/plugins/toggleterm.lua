local lazy_map = require("utils.map").lazy_map

-- Short for "shell open"
local open_mapping = "<leader>so"

function _G.set_term_keymaps()
	local function term_map(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true, buffer = 0 }
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end
		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- For some reason <C-\><C-n> goes from terminal mode to normal mode
	-- The intention here is to exit the terminal with <j & k>, q
	term_map("t", "jk", [[<C-\><C-n>]])
	term_map("t", "kj", [[<C-\><C-n>]])
	term_map({ "n", "v" }, "q", "<CMD>ToggleTerm<CR>")
end

return {
	{
		"akinsho/toggleterm.nvim",
		tag = "v2.8.0",
		keys = lazy_map({
			{ open_mapping, "<CMD>ToggleTerm<CR>" },

			-- Short for "shell run"
			{
				"<Leader>sr",
				function()
					local toggleterm = require("toggleterm")
					local run_command = vim.b.run_command
					if run_command == nil then
						return
					end

					if require("utils.shell").is_powershell then
						run_command = run_command:gsub(" && ", " ; ")
					end

					toggleterm.exec(run_command)
				end,
			},

			-- Short for "shell previous" (command)
			{ "<Leader>sp", "<CMD>ToggleTerm<CR><Up><CR>" },
		}),
		config = function()
			require("utils.shell").set_shell()

			vim.cmd("autocmd! TermOpen term://* lua set_term_keymaps()")

			require("toggleterm").setup({
				direction = "float",

				-- Only relevant if I switch to horizontal
				size = 20,
				shade_terminals = false,
				open_mapping = open_mapping,

				-- whether or not the open mapping applies in insert mode
				insert_mappings = false,

				-- whether or not the open mapping applies in terminal mode
				terminal_mappings = false,
				persist_mode = false,
				float_opts = {
					width = function()
						return math.floor(vim.o.columns * 0.9)
					end,
					height = function()
						return math.floor(vim.o.lines * 0.9)
					end,
				},
			})
		end,
	},
}
