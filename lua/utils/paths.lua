local os = require("utils.os")

local M = {}

M.Config_Path = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":p")
M.Logs_Path = vim.fn.fnamemodify(vim.fn.stdpath("log"), ":p")
M.Data_Path = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")
M.Sessions = M.Logs_Path .. "sessions/"
M.Java_Workspaces = M.Data_Path .. "Java_Workspaces/"
M.Mason_Path = M.Data_Path .. "mason/"
M.Mason_Bin = M.Mason_Path .. "bin/"
M.Resources_Path = M.Config_Path .. "resources/"

-- Deals with linters configs
M.Lint_Fallback = M.Resources_Path .. "lintFallack/"
M.Lint_Ignore = M.Resources_Path .. "lintIgnore/"

-- Deals with formatter configs
M.Format_Fallback = M.Resources_Path .. "formatFallback/"

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

-- Starts at the current file's directory, searches upwards for matching files
-- For example, if root_files is {".git"}, then find where the repo starts

-- If the root_files are not found, fall back on the current file's directory
-- When this happens, we are said to be reading a "single_file"
-- Returns root_dir, single_file
function M.find_project_root(root_files)
	if root_files == nil then
		root_files = { ".git" }
	end
	-- Check for a root directory and set single_file_mode accordingly
	local root_dir =
		vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1])

	local single_file = root_dir == nil
	if single_file then
		root_dir = vim.fn.expand("%:p:h")
	end

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	return root_dir, single_file
end

return M
