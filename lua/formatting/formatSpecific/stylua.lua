local paths = require("utils.paths")

return {
	command = paths.Mason_Bin .. "stylua",
	args = {
		"--config-path",
		paths.Format_Fallback .. "stylua.toml",
		"--stdin-filepath",
		"$FILENAME",
		"-",
	},
}
