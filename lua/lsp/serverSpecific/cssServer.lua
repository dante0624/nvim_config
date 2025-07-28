local mason_bin = require("utils.paths").Mason_Bin

--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			mason_bin .. "vscode-css-language-server",
			"--stdio",
		},
		single_file_support = true,

		-- https://code.visualstudio.com/docs/languages/css#_customizing-css-scss-and-less-settings
		post_init_settings = {
			css = {
				lint = {
					-- This just fixes some css linting error
					validProperties = {},
				},
			},
		},
	}
	return server_config
end

return get_server_config
