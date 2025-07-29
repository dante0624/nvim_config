local os = require("utils.os")

local M = {}

M.Config_Path = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":p")
M.Logs_Path = vim.fn.fnamemodify(vim.fn.stdpath("log"), ":p")
M.Data_Path = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")
M.Sessions = M.Logs_Path .. "sessions/"
M.Java_Workspaces = M.Data_Path .. "Java_Workspaces/"
M.Mason_Path = M.Data_Path .. "mason/"
M.Mason_Bin = M.Mason_Path .. "bin/"

--- Take a full file path and replace the file_separator characters.
--- Makes it safe to use as a single file's name.
--- Got this basic idea from persistence.nvim plugin
--- @param path string
--- @return string serialized_path
function M.serialize_path(path)
	local file_separator = os.is_windows and "[\\:]" or "/"
	local serialized_path, _ = path:gsub(file_separator, "%%")
	return serialized_path
end

--- Starts at the current file's directory, searches upwards for matching files
---
--- For example, if root_files is {".git"}, then find where the repo starts
--- If the root_files are not found, fall back on the current file's directory
--- When this happens, we are said to be reading a "single_file"
--- @param root_files string[]? starting point
--- @return string root_dir the found root, or the current file's directory
--- @return boolean is_single_file true if the root_dir is not part of a project.
function M.find_project_root(root_files)
	if root_files == nil then
		root_files = { ".git" }
	end
	-- Check for a root directory and set single_file_mode accordingly
	local root_dir =
		vim.fs.dirname(vim.fs.find(root_files, {
			upward = true,
			path = vim.fn.expand("%:p"),
		})[1])

	local is_single_file = root_dir == nil
	if is_single_file then
		root_dir = vim.fn.expand("%:p:h")
	end

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	return root_dir, is_single_file
end

return M
