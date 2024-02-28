local mason_bin = require("utils.paths").Mason_Bin

return {
	cmd = {
		mason_bin .. "vscode-css-language-server",
		"--stdio",
	},
	pre_attach_settings = {
		css = {
			lint = {
				-- This just fixes some css linting error
				validProperties = {},
			},
		},
	},
	single_file_support = true,
}
