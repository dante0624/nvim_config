local os = require("utils.os")

return {
	{
		"nvim-treesitter/nvim-treesitter",
		tag = "v0.9.3",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Most OS can install cc pretty easily, except for windows
			-- Zig is the easiest compiler to get on Windows
			local treesitter_compilers
			if os.is_windows then
				treesitter_compilers = { "zig" }
			else
				treesitter_compilers = { "cc" }
			end

			require("nvim-treesitter.install").compilers = treesitter_compilers
			require("nvim-treesitter.install").prefer_git = true
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				indent = { enable = true },

				-- Treesitter for json sucks, and the default syntax works
				ensure_installed = {
					"lua",
					"python",
					"java",
					"html",
					"css",
					"javascript",
                    "typescript",

					-- If I don't have this, WSL bugs out on every comment
					"comment",

					-- Needed for viewing hover information
					"markdown",
					"markdown_inline",
				},
			})
		end,
	},
}
