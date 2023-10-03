return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		tag = "3.7",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim", -- version of this plugin is locked by telescope.lua file
		},
		init = function()
			local cmdline_arg = vim.v.argv[3]
			if cmdline_arg ~= nil and vim.fn.isdirectory(cmdline_arg) == 1 then
				vim.cmd("do User started_on_directory")
			end
		end,
		event = "User started_on_directory",
		keys = {
			-- Normal Tree
			{'t<CR>', '<Cmd>Neotree<CR>', mode = {"n", "v"}},
			{'to', '<Cmd>Neotree action=show<CR>', mode = {"n", "v"}}, -- Open "quietly" (without going to the tree)

			-- Git Status Tree
			{'ts', '<Cmd>Neotree git_status<CR>', mode = {"n", "v"}},

			-- Buffers Tree
			{'tb', '<Cmd>Neotree buffers<CR>', mode = {"n", "v"}},

			-- Other
			{'tf', '<Cmd>Neotree reveal_force_cwd<CR>', mode = {"n", "v"}}, -- Reveal focuses on the current file
			{'tq', '<Cmd>Neotree action=close<CR>', mode = {"n", "v"}},
		},
		opts = {
        	close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
			window = {
				width = 35,
				mappings = {
					-- New
					["s"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "s" }},
					["sc"] = { "order_by_created", nowait = false },
					["sd"] = { "order_by_diagnostics", nowait = false },
					["sg"] = { "order_by_git_status", nowait = false },
					["sm"] = { "order_by_modified", nowait = false },
					["sn"] = { "order_by_name", nowait = false },
					["ss"] = { "order_by_size", nowait = false },
					["st"] = { "order_by_type", nowait = false },
					["h"] = "open_split",
					["v"] = "open_vsplit",
					["c"] = "close_node",
					["C"] = "close_all_nodes",
					["y"] = "copy_to_clipboard",

					-- Setting keys to nothing
					["."] = "noop",
					["<bs>"] = "noop",
					["[g"] = "noop",
					["]g"] = "noop",
					["<C-x>"] = "noop",
					["<Space>"] = "noop",
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
				},
			},
			commands = {
				open_silently = function(state)
					local cmds = require("neo-tree.sources.filesystem.commands")
					local node = state.tree:get_node()
					local current_buff = vim.fn.expand('#:p') -- Need alternative because the current buffer is the tree

					if node.type == "directory" then
						cmds.open(state)
						return
					end

					-- If we are currently looking at the [No Name] buffer
					if current_buff == "" then
						cmds.open(state)
						vim.cmd("Neotree") -- Return focus to the tree

					-- If we are currently looking at a non-null buffer
					else
						vim.cmd("badd "..node.path)
					end

				end,
				open_and_go = function(state)
					local cmds = require("neo-tree.sources.filesystem.commands")
					local node = state.tree:get_node()

					cmds.open(state)

					if node.type == "file" then
						vim.cmd("Neotree action=close")
					end
				end,
			},
			filesystem = {
				window = {
					mappings = {
						-- New
						["-"] = "navigate_up",
						["fs"] = "filter_on_submit",
						["fd"] = "clear_filter",
						["gk"] = "prev_git_modified",
						["gj"] = "next_git_modified",
						["F"] = "fuzzy_finder",
						["S"] = "fuzzy_sorter",

						-- Setting keys to nothing
						["/"] = "noop",
						["#"] = "noop",

						-- The custom mappings
						["O"] = "set_root_or_open",
					},
				},
				commands = {
					set_root_or_open = function(state)
						local cmds = require("neo-tree.sources.filesystem.commands")
						local node = state.tree:get_node()
						if node.type == "file" then
							cmds.open(state)
						else
							cmds.set_root(state)
						end
					end,
				},
			},
			buffers = {
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
						added     = "",
						deleted   = "",
						modified  = "",
						renamed   = "",
						-- Status type
						untracked = "",
						ignored   = "",
						unstaged  = "",
						staged    = "",
						conflict  = "",
					},
				},
			},
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		tag = "nerd-v2-compat",
	},
	{
		"MunifTanjim/nui.nvim",
		tag = "0.2.0",
	},
}

