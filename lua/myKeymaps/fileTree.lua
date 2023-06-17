local buffers = require("utils.buffers")

-- In myPlugin.lua, this function gets used, and attached the NvimTree
-- Source: github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach - Scroll to Bottom
function Tree_On_Attach(bufnr)
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
		api.tree.close() -- Close the tree so we are focused on the current buffer, not the tree
		local go_back  = not buffers.Is_Empty() -- true iff the current buffer isn't [No Name]
		api.tree.open() -- Go back to the tree

		local node = api.tree.get_node_under_cursor()

		api.node.open.edit()

		if node.type == "directory" then
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

