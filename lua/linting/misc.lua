local M = {}

M.linter_settings_prefix = "linting.lintSpecific."

-- There is no built in way to make a deep copy of a table in lua
-- This takes a table of default linter settings, and roughly copies it
-- Just copies the depth 1 values, and all the arguments
function M.copy_default(name)
	local default_linter_settings = require(M.linter_settings_prefix .. name)
	local ignore_linter_settings = {}

	-- Shallow copy
	for k, v in pairs(default_linter_settings) do
		ignore_linter_settings[k] = v
	end

	-- Now copy over the args
	ignore_linter_settings.args = {}
	for _, arg in ipairs(default_linter_settings.args) do
		table.insert(ignore_linter_settings.args, arg)
	end

	return ignore_linter_settings
end

return M
