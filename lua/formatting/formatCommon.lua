local local_map = require("utils.map").local_map

local formatter_settings_prefix = "formatting.formatSpecific."

local M = {}

function M.setup()
	function FormatInfo()
		local showTable = require("utils.showTable")
		local formatters = require("conform").formatters
		showTable(formatters, "((Format Info))")
	end
end


M.already_configured = {}


--[[ This is the function which should be called by each filetype under ftplugin
Adds the correct setting to the plugin's formatters table (if needed)
Names is a list of linter names, which will be applied in order
lsp_fallback = { true | false | "always" } ]]
function M.setup_formatters(names, lsp_fallback)
	local conform = require("conform")

	for _, name in ipairs(names) do
		if not M.already_configured[name] then
			--Update the plugin's formatters table
			local settings = require(formatter_settings_prefix .. name)
			settings.inherit = false
			conform.formatters[name] = settings

			-- Mark it as configured
			M.already_configured[name] = true
		end
	end

	-- Set a local keymap
	local_map("", "<leader>ro", function()
		conform.format({
			formatters = names,
			lsp_fallback = lsp_fallback,
		})
	end)
end


