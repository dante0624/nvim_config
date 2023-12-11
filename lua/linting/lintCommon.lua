local lint_tbl = require("lint")
local linters = lint_tbl.linters
local try_lint = lint_tbl.try_lint
local showTable = require("utils.showTable")

local M = {}

-- Defines a new global method for debugging table information
function M.setup()
	function LintInfo()
		showTable(linters, "((Lint Info))")
	end
end

-- Only configures a linter if it hasn't been configured yet
function M.safe_configure(linter_name)
	--[[ Checks if it was already configured
	The nvimLint plugin author already configured several linter names
	Mine generally begin with mason_ because they reference a full mason path
	It also makes my linter_names unique from the plugin author's.]]
	if linters[linter_name] then
		return
	end

	-- Set to my configuration
	linters[linter_name] = require("linting.lintSpecific." .. linter_name)
end

-- This is the function which should be called by each filetype under ftplugin
function M.setup_linters(linter_names)
	-- These will group which linters can be called on stdin and which cannot
	local stdin_linters = {}
	local file_linters = {}

	-- First configure everything and group everything
	for _, linter_name in ipairs(linter_names) do
		M.safe_configure(linter_name)

		if linters[linter_name].stdin then
			table.insert(stdin_linters, linter_name)
		else
			table.insert(file_linters, linter_name)
		end
	end

	-- The stdin linters
	vim.api.nvim_create_autocmd(
		{"BufWinEnter", "InsertLeave", "TextChanged",},
		{
			buffer = 0,
			callback = function()
				for _, linter_name in ipairs(stdin_linters) do
					try_lint(linter_name)
				end
			end,
		}
	)

	-- The file linters
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = 0,
		callback = function()
			for _, linter_name in ipairs(file_linters) do
				try_lint(linter_name)
			end
		end,
	})
end

return M
