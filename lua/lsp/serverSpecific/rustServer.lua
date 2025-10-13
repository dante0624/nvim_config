local mason_bin = require("utils.paths").Mason_Bin

--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = { mason_bin .. "rust-analyzer" },

		single_file_support = true,

		-- https://rust-analyzer.github.io/book/configuration.html
		post_init_settings = {
			['rust-analyzer'] = {
				-- If true, runs "cargo check" on save for extra diagnostics
				-- They feel repetitive with rust-analyzer's diagnostics
				-- I always want LSPs to "read" from nvim buffers, not files
				-- So I inherently dislike anything that requires me to save
				checkOnSave = false,
			},
		},
	}

	return server_config
end

return get_server_config
