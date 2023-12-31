--[[ TODO:
Make default linters look for config first, then fallback if none found
	Implement this if I'm on a team that puts the configs in the repos

	The settings on the filesystem should add new table entries:
		"config_names" (all the names that the config files can have)
		"arg_num" (the index of arg where we should put this)
	When we load it from the filesystem for the first time we should:
		Search upwards for the files
		If we find one, then put it where the "arg_num" specifies
		Otherwise leave that arg alone (should be the fallback by default)
		Then place this new settings table in M.lint_settings.default
	Extra:
		Update all nameIgnore settings to use this new "arg_num" entry
]]

local linter_settings_prefix = require("linting.misc").linter_settings_prefix

local M = {}

function M.setup()
	function LintInfo()
		local showTable = require("utils.showTable")
		local linters = require("lint").linters
		showTable(linters, "((Lint Info))")
	end
end

--[[ Some linters have very strict diagnostics about best practices
These are helpful before commiting, but are annoying in early development
Sometimes it is nice to ignore the more strict diagnostics
So some linters have 2 settings, "default" and "ignore"
	Some linters only have 1 setting, which is just the default

For saved linter settings on the filesystem, the filename convention is:
	"name" and "nameIgnore"
	if it is just "name", then use the defualt

This table exists to load those settings into RAM
We do this so we can switch between them quickly later on
Once a linter is set up, it is guaranteed to be in "default" subtable.
	It will also be in "ignore" if and only if the ignore setting exists ]]
M.lint_settings = {
	default = {},
	ignore = {},
}

-- Put either default or ignore settings into the plugin's linter table
-- This decides which one actually gets used
function M.update_strictness(names)
	local linters = require("lint").linters

	local function set_default(name)
		linters[name] = M.lint_settings.default[name]
	end

	-- Falls back on default, if the ignore setting doesn't exist
	local function set_ignore(name)
		if M.lint_settings.ignore[name] then
			linters[name] = M.lint_settings.ignore[name]
		else
			set_default(name)
		end
	end

	local set
	if vim.g.ignore_strict_diagnostics == true then
		set = set_ignore
	else
		set = set_default
	end

	-- We can pass in the name of specific linters we want to update
	-- If nothing is passed in, then update all the linters
	if names then
		for _, name in ipairs(names) do
			set(name)
		end
	else
		for name, _ in pairs(linters) do
			set(name)
		end
	end
end

-- This is the function which should be called by each filetype under ftplugin
-- Adds the linter setting(s) to this module's tables if needed
-- Also adds the correct setting to the plugin's linter table
function M.setup_linters(names)
	local try_lint = require("lint").try_lint

	-- Tracks the names which were set up for the first time
	local newly_set_up = {}

	for _, name in ipairs(names) do
		if M.lint_settings.default[name] == nil then
			-- This is guaranteed to exist on the filesystem
			local settings_default = require(linter_settings_prefix .. name)
			M.lint_settings.default[name] = settings_default

			-- This may not exist on the filesystem
			local settings_ignore_exists, settings_ignore = pcall(
				require, linter_settings_prefix .. name .. "Ignore"
			)
			if settings_ignore_exists then
				M.lint_settings.ignore[name] = settings_ignore
			end

			table.insert(newly_set_up, name)
		end
	end

	-- This adds the correct setting into the plugin's table
	M.update_strictness(newly_set_up)

	-- The stdin linters
	vim.api.nvim_create_autocmd(
		{ "BufWinEnter", "InsertLeave", "TextChanged", "User call_lint", },
		{
			buffer = 0,
			callback = function()
				for _, name in ipairs(names) do
					if M.lint_settings.default[name].stdin == true then
						try_lint(name)
					end
				end
			end,
		}
	)

	-- The file linters
	vim.api.nvim_create_autocmd(
		{ "BufWinEnter", "BufWritePost", "User call_lint", },
		{
			buffer = 0,
			callback = function()
				-- Useful for BufWinEnter event, as the buffer may be modified
				-- If so, do not lint because diagnostics may be outdated
				if vim.api.nvim_buf_get_option(0, "modified") then
					return
				end
				for _, name in ipairs(names) do
					if M.lint_settings.default[name].stdin ~= true then
						try_lint(name)
					end
				end
			end,
		}
	)
end

return M
