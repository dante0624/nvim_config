local M = {}

-- Defines a new global method for debugging table information
function M.setup()
	function LintInfo()
		local showTable = require("utils.showTable")
		local linters = require("lint").linters
		showTable(linters, "((Lint Info))")
	end
end

-- This is the function which should be called by each filetype under ftplugin
function M.setup_linters(linter_names)
	local lint_tbl = require("lint")
	local linters = lint_tbl.linters
	local try_lint = lint_tbl.try_lint

	-- These will group which linters can be called on stdin and which cannot
	local stdin_linters = {}
	local file_linters = {}

	-- First configure everything and group everything
	for _, linter_name in ipairs(linter_names) do
		--[[ The nvimLint author already configured several linter names
		Mine begin with mason_ because they reference a full mason path
		It also makes my linter_names unique from the plugin author's.]]
		local mason_name = "mason_" .. linter_name

		if linters[mason_name] == nil then
			linters[mason_name] = require(
				"linting.lintSpecific." .. linter_name
			)
		end

		if linters[mason_name].stdin then
			table.insert(stdin_linters, mason_name)
		else
			table.insert(file_linters, mason_name)
		end
	end

	-- The stdin linters
	vim.api.nvim_create_autocmd(
		{"BufWinEnter", "InsertLeave", "TextChanged",},
		{
			buffer = 0,
			callback = function()
				for _, mason_name in ipairs(stdin_linters) do
					try_lint(mason_name)
				end
			end,
		}
	)

	-- The file linters
	vim.api.nvim_create_autocmd({"BufWinEnter", "BufWritePost"}, {
		buffer = 0,
		callback = function()
			-- Useful for BufWinEnter event, as the buffer may be modified
			-- If so, do not lint because diagnostics may be outdated
			if vim.api.nvim_buf_get_option(0, "modified") then
				return
			end
			for _, mason_name in ipairs(file_linters) do
				try_lint(mason_name)
			end
		end,
	})
end

return M
