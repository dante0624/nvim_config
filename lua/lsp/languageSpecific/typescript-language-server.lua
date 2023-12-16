local utils = require("utils.directories")

return {
	init_options = {
		hostInfo = 'neovim',
		tsserver = {
			logDirectory = utils.Logs_Dir,
			-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
			logVerbosity = 'off',
		},
	},
}

