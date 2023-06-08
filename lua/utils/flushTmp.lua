local dir = require("utils.directories")
local M = {}

function M.Java_Workspaces()
	vim.cmd("silent! !rm -r " .. dir.Java_Workspaces)
end

function M.Views()
	vim.cmd("silent! !rm -r " .. dir.Logs_Dir.."view/")
end

function M.LSP_Log()
	vim.cmd("silent! !rm -r " .. dir.Logs_Dir .. "lsp.log")
end

return M

