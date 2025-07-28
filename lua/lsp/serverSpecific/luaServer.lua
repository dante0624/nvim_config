local mason_bin = require("utils.paths").Mason_Bin

--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = { mason_bin .. "lua-language-server" },
		single_file_support = true,

		-- https://luals.github.io/wiki/settings/
		post_init_settings = {
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
	}

	return server_config
end

return get_server_config
