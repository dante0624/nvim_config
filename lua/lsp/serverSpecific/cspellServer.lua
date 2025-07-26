local paths = require("utils.paths")

--- @param lsp_root_dir string the root directory for the LSP server.
--- @return ServerConfig
local function get_server_config(lsp_root_dir)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			paths.Mason_Bin .. "cspell-lsp",

			-- Option 1, use per-workspace cspell.json files
			"--config", lsp_root_dir .. "cspell.json",

			-- Option 2, use a single, global cspell.json file
			-- "--config", paths.Data_Path .. "cspell.json",

			"--sortWords",
			"--stdio",
		},

		--[[
		single_file_support = false because of the code actions:
			"AddToUserWordsConfig" and "AddToWorkspaceWordsConfig"

		During these, the LSP determines a directory to create / modify cspell.json
		The LSP uses the following places in order:
			1. CLI argument --config, -c (optional)
			2. Search upward for cspell.json from the file with the diagnostic
			3. The provided root_dir used at lsp-initialization

		The first two are optional (since the upward search might return nothing).
		So, this root_dir is the last resort.
		If this is nil, the code actions will error out.
		]]

		single_file_support = false,
	}

	return server_config
end

return get_server_config
