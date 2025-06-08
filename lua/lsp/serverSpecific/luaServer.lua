local mason_bin = require("utils.paths").Mason_Bin

return {
	cmd = { mason_bin .. "lua-language-server" },
	pre_attach_settings = {
		Lua = {
			runtime = {
				-- The version used by Neovim
				version = 'LuaJIT',
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					-- Where the lua code for neovim is written
					vim.env.VIMRUNTIME,
				},
				-- Doing this would also pull in all plugins.
				-- However, this is much slower
				-- library = vim.api.nvim_get_runtime_file("", true)
			},
		},
	},
	single_file_support = true,
}
