local utils = require("utils.directories")
local os = require("utils.os")

local npmLocation
if os.is_windows then
	npmLocation = "/c/Program Files/nodejs/npm"
else
	npmLocation = "" -- TODO: Set this when I need to
end

return {
	init_options = {
		tsserver = {
			logDirectory = utils.Logs_Dir,
			logVerbosity = 'off', -- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
		},
		npmLocation = npmLocation,
	},
}

