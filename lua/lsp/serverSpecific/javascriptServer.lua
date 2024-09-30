local paths = require("utils.paths")

local ignored_message_substrings = {
	"'browser' is not defined.",
	"Cannot find name 'browser'.",
	"implicitly has an 'any' type, but a better type may be inferred from usage.",
}

local filter_func = function(diagnostic)
	for _, substring in ipairs(ignored_message_substrings) do
		if string.find(diagnostic.message, substring) then
			return false
		end
	end

	return true
end

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
	post_attach_settings = {
		settings = {
			implicitProjectConfiguration = {
				checkJs = true,
				strictNullChecks = false,
			},
		},
	},
	single_file_support = true,
	diagnostic_filters = {
		normal = filter_func,
		strict = filter_func,
	},
}
