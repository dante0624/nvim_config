local os = require("utils.os")

local M = {}

M.Logs_Path = vim.fn.fnamemodify(vim.fn.stdpath("log"), ":p")
M.Data_Path = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")
M.Sessions = M.Logs_Path .. "sessions/"
M.Java_Workspaces = M.Data_Path .. "Java_Workspaces/"
M.Mason_Path = M.Data_Path .. "mason/"
M.Mason_Bin = M.Mason_Path .. "bin/"
M.Resources_Path = vim.fn.fnamemodify(
	vim.fn.stdpath("config"), ":p"
) .. "resources/"

-- Deals with linters configs
M.Lint_Fallback = M.Resources_Path .. "lintFallack/"
M.Lint_Ignore = M.Resources_Path .. "lintIgnore/"

-- Got this basic idea from persistence.nvim plugin
function M.serialize_path(path)
	local file_separator
	if os.is_windows then
		file_separator = "[\\:]"
	else
		file_separator = "/"
	end

	return path:gsub(file_separator, "%%")
end

return M

