local mason_bin = require("utils.paths").Mason_Bin

return {
	cmd = {
		mason_bin .. "pyright-langserver",
		"--stdio",
	},
	pre_attach_settings = {
		python = {
			analysis = {
				typeCheckingMode = "on",
			},
		},
	},
}

