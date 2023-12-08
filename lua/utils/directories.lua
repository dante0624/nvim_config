local os = require("utils.os")

local M = {}

M.Config_Dir = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":p")
M.Logs_Dir = vim.fn.fnamemodify(vim.fn.stdpath("log"), ":p")
M.Data_Dir = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")
M.Sessions = M.Logs_Dir .. "sessions/"
M.Java_Workspaces = M.Data_Dir .. "Java_Workspaces/"
M.Mason_Dir = M.Data_Dir .. "mason/"

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

