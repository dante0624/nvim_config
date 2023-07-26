local utils = require("utils.directories")
local os = require("utils.os")

local npmLocation
if os.is_windows then
	npmLocation = "/c/Program Files/nodejs/npm"
else
	npmLocation = "" -- TODO: Set this when I need to
end

local javascriptServerParams = {
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

vim.api.nvim_create_autocmd('LspAttach', {
	pattern = { "*.js", },
	callback = function()
		vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", javascriptServerParams)
	end,
})

return {
	init_options = {
		tsserver = {
			logDirectory = utils.Logs_Dir,
			logVerbosity = 'off', -- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
		},
		npmLocation = npmLocation,
	},
}

