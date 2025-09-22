local map = require("utils.map").map
local default_key_map_modes = require("utils.map").default_key_map_modes

return {
	{
		"romgrk/barbar.nvim",
		tag = "v1.9.1",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"lewis6991/gitsigns.nvim",
		},
		lazy = false, -- Don't lazy load, for my session management

		-- Without this, barbar will call setup() a second time
		init = function()
			vim.g.barbar_auto_setup =false
		end,

		config = function()
			require("barbar").setup({
				animation = false,
				insert_at_end = true,
				focus_on_close = "left",
				no_name_title = "[No Name]",
			})

			-- Manipulate Buffer Tabs
			map("n", "<S-TAB>", "<Cmd>BufferPrev<CR>")
			map("n", "<TAB>", "<Cmd>BufferNext<CR>")
			map(default_key_map_modes, "<leader><S-TAB>", "<Cmd>BufferMovePrev<CR>")
			map(default_key_map_modes, "<leader><TAB>", "<Cmd>BufferMoveNext<CR>")

			-- Close Buffer Tabs
			map(default_key_map_modes, "<leader>e", "<Cmd>BufferClose<CR>")
			map(default_key_map_modes, "<leader>E", "<Cmd>BufferCloseBuffersRight<CR>")

			-- O for "open" and then select a specific buffer
			map(default_key_map_modes, "<leader>oa", "<Cmd>BufferGoto 1<CR>")
			map(default_key_map_modes, "<leader>os", "<Cmd>BufferGoto 2<CR>")
			map(default_key_map_modes, "<leader>od", "<Cmd>BufferGoto 3<CR>")
			map(default_key_map_modes, "<leader>of", "<Cmd>BufferGoto 4<CR>")
			map(default_key_map_modes, "<leader>og", "<Cmd>BufferGoto 5<CR>")
		end,
	},
}
