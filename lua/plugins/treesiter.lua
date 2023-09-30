local os = require("utils.os")

return {{
	'nvim-treesitter/nvim-treesitter',
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		-- Zig is the easiest compiler to get on Windows and WSL, but not on for MacOS or Linux
		local treesitter_compilers
		if os.is_windows or os.is_wsl then
			treesitter_compilers = { "zig" }
		else
			treesitter_compilers = { "cc" }
		end

		require('nvim-treesitter.install').compilers = treesitter_compilers
		require('nvim-treesitter.configs').setup({
			highlight = { enable = true },

			-- Note that treesitter for json sucks, and the default syntax works perfectly
			ensure_installed = {
				"comment", -- If I don't have this, WSL bugs out on every comment
				"lua",
				"python",
				"java",
				"kotlin",
				"html",
				"css",
				"javascript",
			},

			-- Configure and setup autotag plugin because it works better on bootstrapping
			autotag = {
				enable = true,
				enable_rename = false,
				enable_close = true,
				enable_close_on_slash = true,
				filetypes = { "html" , "xml" },
			},
		})
	end,
}}

