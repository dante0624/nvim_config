local paths = require("utils.paths")

local global_cspell_json_path = paths.Data_Path .. "cspell.json"

--- @param server_config_params ServerConfigParams
--- @return string cspell_json_path
local function resolve_cspell_json_path(server_config_params)
	if server_config_params.is_single_file then
		return global_cspell_json_path
	end

	for name, type in vim.fs.dir(server_config_params.root_dir) do
		if name == "cspell.json" and type == "file" then
			return server_config_params.root_dir .. "cspell.json"
		end
	end

	return global_cspell_json_path
end

--- @param server_config_params ServerConfigParams
--- @return ServerConfig
local function get_server_config(server_config_params)
	local cspell_json_path = resolve_cspell_json_path(server_config_params)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			paths.Mason_Bin .. "cspell-lsp",

			"--config", cspell_json_path,
			"--sortWords",
			"--stdio",
		},

		-- If is_single_file, I default to using the global cspell.json file
		-- In this case, I provide a `nil` root_dir and the server still works
		single_file_support = true,
	}

	return server_config
end

return get_server_config
