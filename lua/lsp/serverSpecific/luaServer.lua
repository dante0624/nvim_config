local os_type = require("utils.os_type")
local paths = require("utils.paths")

local annotations_locations = {
	-- Annotations for neovim source code
	-- There is some way to also get annotations for plugins, can add later
	vim.env.VIMRUNTIME,
}
if os_type.is_macos then
	-- Annotations for hammerspoon
	table.insert(annotations_locations, paths.Home .. ".hammerspoon/Spoons/EmmyLua.spoon/annotations")
end

--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = { paths.Mason_Bin .. "lua-language-server" },
		single_file_support = true,

		-- https://luals.github.io/wiki/settings/
		post_init_settings = {
			Lua = {
				runtime = {
					-- The version used by Neovim
					version = 'LuaJIT',
				},
				workspace = {
					checkThirdParty = false,
					library = annotations_locations,
				},
			},
		},
	}

	return server_config
end

return get_server_config
