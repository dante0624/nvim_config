return {{
	-- the colorscheme should be available when starting Neovim

	"folke/tokyonight.nvim",
	tag = "v2.3.0",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		-- load the colorscheme here
		vim.cmd([[colorscheme tokyonight]])

		-- Making the comments and the line numbers pop a little more
		vim.cmd.highlight("CursorLine", "guibg=none")
		vim.o.cursorline = true
		vim.cmd.highlight("Comment", "guifg=#737aa2")
		vim.cmd.highlight("LineNR", "guifg=#737aa2")
		vim.cmd.highlight("CursorLineNR", "guifg=#73a0a2")

		-- Remove background highlighting on folds
		vim.cmd.highlight("Folded", "guibg=none")

		-- Make DocStrings have the same hue as normal strings, just less bright and italicized
		vim.cmd.highlight("@string.documentation", "guifg=#a6c478")
		vim.cmd.highlight("@string.documentation", "cterm=italic")
		vim.cmd.highlight("@string.documentation", "gui=italic")
	end,
}}

