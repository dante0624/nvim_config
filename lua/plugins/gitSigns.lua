local function git_on_attach(bufnr)
	local git_signs = package.loaded.gitsigns

	local function map(mode, l, r, opts)
		opts = opts or {}
		opts.buffer = bufnr
		vim.keymap.set(mode, l, r, opts)
	end

	-- Navigation
	map("n", "<leader>gj", git_signs.next_hunk)
	map("n", "<leader>gk", git_signs.prev_hunk)

	-- Actions
	map("n", "<leader>gs", git_signs.stage_hunk)
	map("v", "<leader>gs", function()
		git_signs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end)

	map("n", "<leader>gS", git_signs.stage_buffer)
	map("n", "<leader>gu", git_signs.undo_stage_hunk)

	map("n", "<leader>gr", git_signs.reset_hunk)
	map("v", "<leader>gr", function()
		git_signs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end)

	map("n", "<leader>gR", git_signs.reset_buffer)
	map("n", "<leader>gp", git_signs.preview_hunk)
	map("n", "<leader>gb", git_signs.blame_line)
	map("n", "<leader>gd", git_signs.diffthis)
	map("n", "<leader>gt", git_signs.toggle_deleted)
end

return {
	{
		"lewis6991/gitsigns.nvim",
		tag = "v0.6",
		lazy = false, -- Don't lazy load, for my session management
		opts = {
			on_attach = git_on_attach,
			current_line_blame_opts = {
				virt_text = false,
			},
		},
	},
}
