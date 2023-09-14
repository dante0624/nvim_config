local dir = require("utils.directories")
local M = {}

-- Contains the functions which flush out an single, set of tmp files
-- These set of tmp files together all serve a single purpose
local single_flush = {}

function single_flush.Java_Workspaces()
	vim.cmd("!rm -r " .. dir.Java_Workspaces)
end

function single_flush.Views()
	vim.cmd("!rm -r " .. dir.Logs_Dir.."view/")
end

function single_flush.LSP_Log()
	vim.cmd("!rm -r " .. dir.Logs_Dir .. "lsp.log")
end

function single_flush.Sessions()
	vim.cmd("!rm -r " .. dir.Data_Dir .. "sessions/")
	vim.cmd("!rm -r " .. dir.Data_Dir .. "auto_session/")
end

function M.All()
	for _, func in pairs(single_flush) do
		func()
	end
end

M = vim.tbl_extend("keep", M, single_flush)

return M

