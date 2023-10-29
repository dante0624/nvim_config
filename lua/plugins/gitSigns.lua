local function git_on_attach(bufnr)
	local gs = package.loaded.gitsigns

	local function map(mode, l, r, opts)
		opts = opts or {}
		opts.buffer = bufnr
		vim.keymap.set(mode, l, r, opts)
	end

	-- Navigation
	map('n', '<leader>sj', function()
		if vim.wo.diff then return '<leader>hj' end
		vim.schedule(function() gs.next_hunk() end)
		return '<Ignore>'
	end, {expr=true})

	map('n', '<leader>sk', function()
		if vim.wo.diff then return '<leader>hk' end
		vim.schedule(function() gs.prev_hunk() end)
		return '<Ignore>'
	end, {expr=true})

	-- Actions
	-- map('n', '<leader>hs', gs.stage_hunk)
	map('n', '<leader>sr', gs.reset_hunk)
	-- map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end)
	map('v', '<leader>sr', function() gs.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end)
	-- map('n', '<leader>hS', gs.stage_buffer)
	-- map('n', '<leader>hu', gs.undo_stage_hunk)
	map('n', '<leader>sR', gs.reset_buffer)
	map('n', '<leader>sp', gs.preview_hunk)
	map('n', '<leader>sb', function() gs.blame_line{full=true} end)
	-- map('n', '<leader>tb', gs.toggle_current_line_blame)
	map('n', '<leader>sd', gs.diffthis)
	-- map('n', '<leader>hD', function() gs.diffthis('~') end)
	-- map('n', '<leader>td', gs.toggle_deleted)

	-- Text object
	-- map({'o', 'x'}, 'ih', '<Cmd><C-U>Gitsigns select_hunk<CR>')
end

return {{
	'lewis6991/gitsigns.nvim',
	tag = "v0.6",
	lazy = false, -- Don't lazy load, for my session management
	opts = {
		on_attach = git_on_attach,
		current_line_blame_opts = {
			virt_text = false,
		},
	},
}}

