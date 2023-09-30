local Map = require("utils.map").Map
local buffers = require("utils.buffers")

-- Describes the keybinds that work within the tree itself
-- Source: github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach - Scroll to Bottom
local function tree_on_attach(bufnr)
	-- All helper functions that github said to use
	local api = require('nvim-tree.api')

	local function opts(desc)
		return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- Add in the default keymappings
	api.config.mappings.default_on_attach(bufnr)

	-- Remove keymappings that I think are dumb
	-- For safety, we overwrite them first (to guarantee they exist) then remove them
	vim.keymap.set('n', '<2-LeftMouse>', '', { buffer = bufnr })
	vim.keymap.del('n', '<2-LeftMouse>', { buffer = bufnr })
	vim.keymap.set('n', '<2-RightMouse>', '', { buffer = bufnr })
	vim.keymap.del('n', '<2-RightMouse>', { buffer = bufnr })
	vim.keymap.set('n', '<C-]>', '', { buffer = bufnr })
	vim.keymap.del('n', '<C-]>', { buffer = bufnr })
	vim.keymap.set('n', '<C-E>', '', { buffer = bufnr })
	vim.keymap.del('n', '<C-E>', { buffer = bufnr })
	vim.keymap.set('n', '<C-T>', '', { buffer = bufnr })
	vim.keymap.del('n', '<C-T>', { buffer = bufnr })
	vim.keymap.set('n', 'H', '', { buffer = bufnr })
	vim.keymap.del('n', 'H', { buffer = bufnr })
	vim.keymap.set('n', 'J', '', { buffer = bufnr })
	vim.keymap.del('n', 'J', { buffer = bufnr })
	vim.keymap.set('n', 'K', '', { buffer = bufnr })
	vim.keymap.del('n', 'K', { buffer = bufnr })
	vim.keymap.set('n', 'c', '', { buffer = bufnr })
	vim.keymap.del('n', 'c', { buffer = bufnr })
	vim.keymap.set('n', 'g?', '', { buffer = bufnr })
	vim.keymap.del('n', 'g?', { buffer = bufnr })

	-- Helper Functions for my custom keybinds
	local function open_silent(_)
		local node = api.tree.get_node_under_cursor()
		local current_buff = vim.fn.expand('#:p') -- Need alternative because the current buffer is the tree
		local go_back  = current_buff ~= "" and node.absolute_path ~= current_buff

		api.node.open.edit()

		if node.type ~= "file" then
			return
		end

		if go_back then
			vim.cmd([[exe "norm \<c-o>"]]) -- Normal command to go to the previous buffer
		end

		buffers.Clean_Empty()
		api.tree.focus()
	end

	local function open_and_go(_)
		local node = api.tree.get_node_under_cursor()

		api.node.open.edit()
		if node.type == "file" then
			api.tree.close()
			buffers.Clean_Empty()
		end
	end

	-- Finally, my custom keymappings
	vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
	vim.keymap.set('n', 'o', open_silent, opts('Open Silent'))
	vim.keymap.set('n', '<CR>', open_and_go, opts('Open and Go'))
	vim.keymap.set('n', 'O', api.tree.change_root_to_node, opts('CD'))
	vim.keymap.set('n', 'A', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
	vim.keymap.set('n', 'y', api.fs.copy.node, opts('Copy'))
end

return {{
	'nvim-tree/nvim-tree.lua',
	commit = 'f5804ce94e06966e0fc1aba9c697c178fc7cb210', -- Windows bug was fixed at this commit, then broken later
	dependencies = {
		'nvim-tree/nvim-web-devicons',
	},
	config = function()
		-- NvimTree: disable netrw at the very start of your init.lua (strongly advised)
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("nvim-tree").setup({
			on_attach = tree_on_attach,
			sync_root_with_cwd = true,
			git = {
				ignore = false, -- Starts off by not ignoring gitignored files
				timeout = 1000, -- Increase from 400ms (default) to 1s
			},
		})


		-- For some reason, lazy loading this plugin with keys = seems to bug out. May be related to session manager
		-- So we just do it the old way with no lazy loading
		Map('', 'tq', '<Cmd>NvimTreeClose<CR>')
		Map('', 't<CR>', '<Cmd>NvimTreeOpen<CR>')
		Map('', 'to', function()
			vim.cmd("NvimTreeOpen")
			local current_buff = vim.fn.expand('#:p') -- Need alternative because the current buffer is the tree
			local go_back  = current_buff ~= ""

			if go_back then
				vim.cmd("b#")
			end
		end)
		Map('', 'tf', '<Cmd>NvimTreeFindFile<CR>')
	end,
}}

