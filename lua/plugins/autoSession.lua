return {{
	'rmagatti/auto-session',
	-- We require BarBar (top tabline) and gitsigns because we configure this to save the state of these plugins
	-- With Barbar, this needs to remember the order of the tabs
	-- With gitsigns, this needs to remember whether or not they were being displayed
	commit = "9a623ccbfd8acf71c0e51f8f957b713a7545a542",
	dependencies = {
		'romgrk/barbar.nvim',
		'lewis6991/gitsigns.nvim',
	},

	config = function()
		-- Need to save global options when we make a session, to restore extra information
		vim.opt.sessionoptions:append('globals')

		local HUD = require("core.myModules.HUD")

		require('auto-session').setup({
			pre_save_cmds = {
				-- From barbar's README.md
				function() vim.api.nvim_exec_autocmds('User', {pattern = 'SessionSavePre'}) end,
				HUD.save_header,
				HUD.save_footer,
				HUD.save_line_numbers,
				HUD.save_git_signs,
			},
			post_restore_cmds = {
				HUD.restore_header,
				HUD.restore_footer,
				HUD.restore_line_numbers,
				HUD.restore_git_signs,
				function()
					local bufnr = vim.fn.bufnr("neo-tree filesystem [1]")
					vim.cmd("silent! bd " .. bufnr)
				end,

			},

			log_level = "error",
			auto_session_suppress_dirs = {
				"/",
				"~/",
				"~/Downloads/",
				"~/Applications/",
			},
		})
	end
}}

