--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		-- Need to install manually, as this is sadly not supported by Mason
		-- First install `coursier` (the package manager for scala)
		-- Then run `cs install metals`
		-- Then put metals onto the path
		cmd = { "metals" },
		single_file_support = true,

		-- https://github.com/scalameta/metals/blob/main/docs/integrations/new-editor.md#initializationoptions
		-- https://github.com/scalameta/metals/blob/main/metals/src/main/scala/scala/meta/internal/metals/InitializationOptions.scala
		init_options = {
			-- All of this is to prevent a popup like "Http server is required for such features as Metals Doctor, do you want to start it now?"
			isHttpEnabled = false,
			doctorProvider = "json",
			doctorVisibilityProvider = false,
			-- Putting true is a lie here, as I'm saying that I have custom handling for Server -> Client requests like
			-- "metals-doctor-run" and others (see Metals github source code for more)
			-- But I don't care, since neovim's LSP client will ignore them and I just want the popup gone
			executeClientCommandProvider = true,
		},

		-- https://scalameta.org/metals/docs/editors/user-configuration
		-- https://github.com/scalameta/metals/blob/main/metals/src/main/scala/scala/meta/internal/metals/UserConfiguration.scala
		post_init_settings = {
			metals = {
				-- For some reason, this makes semantic tokens work better
				bloopSbtAlreadyInstalled = true,
			},
		},
	}
	return server_config
end

return get_server_config
