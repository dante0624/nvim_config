local map = require("utils.map").map
local default_key_map_modes = require("utils.map").default_key_map_modes

local function git_on_attach()
	local git_signs = package.loaded.gitsigns

	-- Navigation
	map(default_key_map_modes, "<leader>gj", git_signs.next_hunk)
	map(default_key_map_modes, "<leader>gk", git_signs.prev_hunk)

	-- Actions
	map({ "n", "o" }, "<leader>gs", git_signs.stage_hunk)
	map({ "x", "s" }, "<leader>gs", function()
		git_signs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end)

	map(default_key_map_modes, "<leader>gS", git_signs.stage_buffer)
	map(default_key_map_modes, "<leader>gu", git_signs.undo_stage_hunk)

	map({ "n", "o" }, "<leader>gr", git_signs.reset_hunk)
	map({ "x", "s" }, "<leader>gr", function()
		git_signs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end)

	map(default_key_map_modes, "<leader>gR", git_signs.reset_buffer)
	map(default_key_map_modes, "<leader>go", git_signs.preview_hunk)
	map(default_key_map_modes, "<leader>gb", git_signs.blame_line)
	map(default_key_map_modes, "<leader>gd", git_signs.diffthis)
	map(default_key_map_modes, "<leader>gt", git_signs.toggle_deleted)
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
