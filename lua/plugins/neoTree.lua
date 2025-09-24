local clean_no_name_buffers = require("utils.buffers").clean_no_name_buffers
local get_listed_user_buffer_ids = require("utils.buffers").get_listed_user_buffer_ids
local default_key_map_modes = require("utils.map").default_key_map_modes


return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		tag = "3.31.1",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",

			-- version of this plugin is locked by telescope.lua file
			"nvim-lua/plenary.nvim",
		},
		-- Normally we lazy load the plugin based on keymappings
		-- However, we also load if the user starts vim on a directory
		init = function()
			local vim_arg = vim.v.argv[3]
			if vim_arg ~= nil and vim.fn.isdirectory(vim_arg) == 1 then
				vim.cmd("do User started_on_directory")
			end
		end,
		event = "User started_on_directory",
		keys = {
			-- Close the tree
			{ "<leader>tq", "<Cmd>Neotree close<CR>", mode = default_key_map_modes },

			-- Netrw-style Tree
			{ "<leader>to", "<Cmd>Neotree<CR>", mode = default_key_map_modes },
			{ "<leader>tp", "<Cmd>Neotree reveal_force_cwd<CR>", mode = default_key_map_modes },

			--[[ 4 Slightly different ways to open the tree on the left (asdf)
			I prefer Netrw-style, because I don't like the split screen
			Main use case is importing a file, but I forgot the full path ]]
			{
				"<leader>ta",
				"<Cmd>Neotree position=left<CR>",
				mode = default_key_map_modes,
			},
			{
				"<leader>ts",
				"<Cmd>Neotree position=left reveal_force_cwd<CR>",
				mode = default_key_map_modes,
			},
			{
				"<leader>td",
				"<Cmd>Neotree position=left action=show<CR>",
				mode = default_key_map_modes,
			},
			{
				"<leader>tf",
				"<Cmd>Neotree position=left action=show reveal_force_cwd<CR>",
				mode = default_key_map_modes,
			},

			-- Git Status Tree
			{ "<leader>tg", "<Cmd>Neotree git_status<CR>", mode = default_key_map_modes },

			-- Buffers Tree
			{ "<leader>tb", "<Cmd>Neotree buffers<CR>", mode = default_key_map_modes },
		},
		opts = {
			close_if_last_window = true,
			window = {
				mappings = {
					-- New keymappings
					["s"] = {
						"show_help",
						nowait = false,
						config = {
							title = "Order by",
							prefix_key = "s",
						},
					},
					["sc"] = { "order_by_created", nowait = false },
					["sd"] = { "order_by_diagnostics", nowait = false },
					["sg"] = { "order_by_git_status", nowait = false },
					["sm"] = { "order_by_modified", nowait = false },
					["sn"] = { "order_by_name", nowait = false },
					["ss"] = { "order_by_size", nowait = false },
					["st"] = { "order_by_type", nowait = false },
					["<C-h>"] = "open_split",
					["<C-v>"] = "open_vsplit",
					["c"] = "close_node",
					["C"] = "close_all_nodes",

					-- Setting keys to nothing
					["."] = "noop",
					["<bs>"] = "noop",
					["<"] = "noop",
					[">"] = "noop",
					["[g"] = "noop",
					["]g"] = "noop",
					["<C-x>"] = "noop",
					["<Space>"] = "noop",
					["P"] = "noop",
					["l"] = "noop",
					["H"] = "noop",
					["oc"] = "noop",
					["od"] = "noop",
					["og"] = "noop",
					["om"] = "noop",
					["on"] = "noop",
					["os"] = "noop",
					["ot"] = "noop",
					["f"] = "noop",
					["t"] = "noop",
					["S"] = "noop",
					["z"] = "noop",
					["e"] = "noop",
					["w"] = "noop",

					-- The custom mappings
					["o"] = "open_silently",
					["<CR>"] = "open_and_go",
					["<C-y>"] = "copy_path_to_paste_register",

					-- Needed to split between normal and visual mode
					-- In normal mode, "copy" the file (can paste to different location)
					-- In visual mode, just use the normal keymap; ie copy the text into register 0
					-- Cannot use the builtin "copy_to_clipboard" because "copy_to_clipboard_visual" is defined
					["y"] = "custom_y_handler",
				},
			},
			commands = {
				-- Open a tree node silently, should work for any source
				open_silently = function(state)
					local cmds = state.commands
					local node = state.tree:get_node()

					if node.type == "directory" then
						cmds.open(state)
						return
					end

					-- If only the [No Name] buffer is currently open
					if #get_listed_user_buffer_ids() == 0 then
						cmds.open(state)

						-- Return focus to the tree
						vim.cmd("Neotree source=last position=" .. state.current_position)

					-- If we are currently looking at a non-null buffer
					else
						vim.cmd("badd " .. node.path)
					end

					-- Always cleanup any potential [No Name] buffers that are still around
					clean_no_name_buffers()
				end,

				-- Open a tree node and go, should work for any source
				open_and_go = function(state)
					local cmds = state.commands
					local node = state.tree:get_node()

					cmds.open(state)

					if node.type == "file" then
						vim.cmd("Neotree action=close")
						clean_no_name_buffers()
					end
				end,

				-- I prefer to paste with "p" from the 0 register
				copy_path_to_paste_register = function(state)
					local node = state.tree:get_node()
					vim.fn.setreg('0', node.path)
					print("Saved complete " .. node.type .. " path to register 0.")
				end,

				custom_y_handler = function(state)
					state.commands.copy_to_clipboard(state)
				end,
			},
			filesystem = {
				group_empty_dirs = true,
				window = {
					position = "current",
					mappings = {
						-- New
						["-"] = "navigate_up",
						["fs"] = "filter_on_submit",
						["fd"] = "clear_filter",
						["gk"] = "prev_git_modified",
						["gj"] = "next_git_modified",
						["F"] = "fuzzy_finder",
						["S"] = "fuzzy_sorter",
						["I"] = "toggle_hidden",

						-- Setting keys to nothing
						["/"] = "noop",
						["#"] = "noop",

						-- The custom mappings
						["O"] = "set_root_or_open",
					},
				},
				commands = {
					set_root_or_open = function(state)
						local cmds = state.commands
						local node = state.tree:get_node()
						if node.type == "file" then
							cmds.open(state)
						else
							-- This line only works from the filesystem source
							-- This makes sense intuitively
							cmds.set_root(state)
						end
					end,
				},
			},
			buffers = {
				window = {
					position = "float",
				},
				follow_current_file = {
					enabled = true,
				},
			},
			git_status = {
				window = {
					position = "float",
				},
			},
			default_component_configs = {
				modified = {
					symbol = "",
				},
				git_status = {
					symbols = {
						added = "",
						deleted = "",
						modified = "",
						renamed = "",
						-- Status type
						untracked = "",
						ignored = "",
						unstaged = "",
						staged = "",
						conflict = "",
					},
				},
			},
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		tag = "nerd-v2-compat",
		lazy = true,
	},
	{
		"MunifTanjim/nui.nvim",
		-- Commit id b1b3dcd6ed8f355c78bad3d395ff645be5f8b6ae removed vim.tbl_islist()
		-- Waiting for a new tag to drop that removes this
		commit = "8d3bce9764e627b62b07424e0df77f680d47ffdb",
		lazy = true,
	},
}
