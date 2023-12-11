local utils = require("utils.directories")
local os = require("utils.os")

-- TODO: Clean up this hack by using a "which" command to find npm location
local npmLocation
if os.is_windows then
	npmLocation = "/c/Program Files/nodejs/npm"
else
	npmLocation = ""
end

return {
	init_options = {
		hostInfo = 'neovim',
		tsserver = {
			logDirectory = utils.Logs_Dir,
			-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
			logVerbosity = 'off',
		},
		npmLocation = npmLocation,
	},
	post_attach_settings = {
		settings = {
			implicitProjectConfiguration = {
				checkJs = true,
				strictNullChecks = false,
			},
			diagnostics = {
				ignoredCodes = {
					2339,
					2531,
					7044,
				},
			},
		},
	}
}

