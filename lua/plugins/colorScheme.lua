return {{
	-- the colorscheme should be available when starting Neovim

	"folke/tokyonight.nvim",
	tag = "v2.3.0",

	-- make sure we load this during startup if it is your main colorscheme
	lazy = false,

	-- make sure to load this before all the other start plugins
	priority = 1000,
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

		-- Make DocStrings have the same hue as normal strings,
		-- just less bright and italicized
		vim.cmd.highlight("@string.documentation", "guifg=#a6c478")
		vim.cmd.highlight("@string.documentation", "cterm=italic")
		vim.cmd.highlight("@string.documentation", "gui=italic")

		-- Make modified buffers have a nice blue color
		vim.cmd.highlight("BufferCurrentMod", "guifg=#7aa2f7")
		vim.cmd.highlight("BufferAlternateMod", "guifg=#5f7ab4")
		vim.cmd.highlight("BufferInactiveMod", "guifg=#5f7ab4")
		vim.cmd.highlight("BufferVisibleMod", "guifg=#5f7ab4")


		-- Make NeoTree have simple colors that make sense to me
		vim.cmd.highlight("NeoTreeDirectoryName", "guifg=#aab1d3")
		vim.cmd.highlight("NeoTreeDirectoryIcon", "guifg=#aab1d3")
		vim.cmd.highlight("NeoTreeDotfile", "guifg=#737aa2", "gui=italic")
		vim.cmd.highlight("NeoTreeGitUntracked", "guifg=#266d6a")
		vim.cmd.highlight("NeoTreeGitModified", "guifg=#426ecd")
	end,
}}

