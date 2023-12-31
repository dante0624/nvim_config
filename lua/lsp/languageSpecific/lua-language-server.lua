local mason_bin = require("utils.paths").Mason_Bin

return {
	cmd = { mason_bin .. "lua-language-server" },
	pre_attach_settings = {
		Lua = {
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
		},
	},
}
