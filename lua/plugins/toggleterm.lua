local local_map = require("utils.map").local_map
local default_key_map_modes = require("utils.map").default_key_map_modes
local alpabetical_key_map_modes = require("utils.map").alpabetical_key_map_modes

-- Short for "shell open"
local open_mapping = "<leader>xo"

function _G.set_term_keymaps()
	-- For some reason <C-\><C-n> goes from terminal mode to normal mode
    local_map("t", "<Esc>", [[<C-\><C-n>]])

	-- All of the following can be used to exit ToggleTerm when in normal mode
	local_map(alpabetical_key_map_modes, "<Esc>", "<CMD>ToggleTerm<CR>")
	local_map(alpabetical_key_map_modes, "q", "<CMD>ToggleTerm<CR>")
	local_map(alpabetical_key_map_modes, ";", "<CMD>ToggleTerm<CR>")
end

return {
	{
		"akinsho/toggleterm.nvim",
		tag = "v2.8.0",
		keys = {
			{ open_mapping, "<CMD>ToggleTerm<CR>", mode = default_key_map_modes },

			-- Short for "execute run command"
			{
				"<Leader>xr",
				function()
					local toggleterm = require("toggleterm")
					local run_command = vim.b.run_command
					if run_command == nil then
						return
					end

					-- Allow buffers to define a function
					-- It must be invoked to return the real run_command as a string
					if type(run_command) == "function" then
						run_command = run_command()
					end

					if require("utils.shell").is_powershell then
						run_command = run_command:gsub(" && ", " ; ")
					end

					toggleterm.exec(run_command)
				end,
				mode = default_key_map_modes,
			},

			-- Short for "execute previous command"
			{ "<Leader>xp", "<CMD>ToggleTerm<CR><Up><CR>", mode = default_key_map_modes },
		},
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
