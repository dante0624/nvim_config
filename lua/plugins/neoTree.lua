local lazy_map = require("utils.map").lazy_map

-- Helper functions for defining my own custom commands in the tree
local function get_neotree_commands(source)
	if source == "filesystem" then
		return require("neo-tree.sources.filesystem.commands")
	end

	-- Applies to git status and buffers
	return require("neo-tree.sources.common.commands")

end

-- Open a tree node silently, should work for any source
local function common_open_silently(state, source)
	local cmds = get_neotree_commands(source)
	local node = state.tree:get_node()

	-- Need alternative because the current buffer is the tree
	local current_buff = vim.fn.expand('#:p')

	if node.type == "directory" then
		cmds.open(state)
		return
	end

	-- If we are currently looking at the [No Name] buffer
	if current_buff == "" then
		cmds.open(state)

		-- Return focus to the tree
		vim.cmd("Neotree")

	-- If we are currently looking at a non-null buffer
	else
		vim.cmd("badd "..node.path)
	end

end

-- Open a tree node and go, should work for any source
local function common_open_and_go(state, source)
	local cmds = get_neotree_commands(source)
	local node = state.tree:get_node()

	cmds.open(state)

	if node.type == "file" then
		vim.cmd("Neotree action=close")
	end
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		tag = "3.7",
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
		keys = lazy_map({
			-- Close the tree
			{'<leader>tq', '<Cmd>Neotree close<CR>'},

			-- Netrw-style Tree
			{'<leader>to', '<Cmd>Neotree<CR>'},
			{'<leader>tp', '<Cmd>Neotree reveal_force_cwd<CR>'},

			--[[ 4 Slightly different ways to open the tree on the left (asdf)
			I prefer Netrw-style, because I don't like the split screen
			Main use case is importing a file, but I forgot the full path ]]
			{
				'<leader>ta',
				'<Cmd>Neotree position=left<CR>'
			},
			{
				'<leader>ts',
				'<Cmd>Neotree position=left reveal_force_cwd<CR>'
			},
			{
				'<leader>td',
				'<Cmd>Neotree position=left action=show<CR>'
			},
			{
				'<leader>tf',
				'<Cmd>Neotree position=left action=show reveal_force_cwd<CR>'
			},

			-- Git Status Tree
			{'<leader>tg', '<Cmd>Neotree git_status<CR>'},

			-- Buffers Tree
			{'<leader>tb', '<Cmd>Neotree buffers<CR>'},

		}),
		opts = {
        	close_if_last_window = true,
			window = {
				mappings = {
					-- New keymappings
					["s"] = { "show_help", nowait=false, config = {
						title = "Order by",
						prefix_key = "s"
					}},
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
					["y"] = "copy_to_clipboard",

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
				},
			},
			filesystem = {
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
						["o"] = "open_silently",
						["<CR>"] = "open_and_go",
					},
				},
				commands = {
					set_root_or_open = function(state)
						local cmds = get_neotree_commands("filesystem")
						local node = state.tree:get_node()
						if node.type == "file" then
							cmds.open(state)
						else
							cmds.set_root(state)
						end
					end,
					open_silently = function(state)
						common_open_silently(state, "filesystem")
					end,
					open_and_go = function(state)
						common_open_and_go(state, "filesystem")
					end
				},
			},
			buffers = {
				window = {
					position = "float",
					mappings = {
						-- The custom mappings
						["o"] = "open_silently",
						["<CR>"] = "open_and_go",
					},
				},
				commands = {
					open_silently = function(state)
						common_open_silently(state, "buffers")
					end,
					open_and_go = function(state)
						common_open_and_go(state, "buffers")
					end
				},
				follow_current_file = {
					enabled = true,
				},
			},
			git_status = {
				window = {
					position = "float",
					mappings = {
						-- The custom mappings
						["o"] = "open_silently",
						["<CR>"] = "open_and_go",
					},
				},
				commands = {
					open_silently = function(state)
						common_open_silently(state, "git_status")
					end,
					open_and_go = function(state)
						common_open_and_go(state, "git_status")
					end
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
		lazy = true,
	},
	{
		"MunifTanjim/nui.nvim",
		tag = "0.2.0",
		lazy = true,
	},
}

