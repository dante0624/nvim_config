local paths = require("utils.paths")

return {
	init_options = {
		hostInfo = 'neovim',
		tsserver = {
			logDirectory = paths.Logs_Path,
			-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
			logVerbosity = 'off',
		},
	},
}

