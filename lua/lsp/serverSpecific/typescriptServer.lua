local paths = require("utils.paths")

return {
	cmd = {
		paths.Mason_Bin .. "typescript-language-server",
		"--stdio",
	},
	init_options = {
		hostInfo = "neovim",
		tsserver = {
			logDirectory = paths.Logs_Path,
			-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
			logVerbosity = "off",
		},
	},
	single_file_support = true,
}


