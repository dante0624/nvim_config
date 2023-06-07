local dir = require("utils.directories")
local M = {}

function M.Java_Workspaces()
	vim.cmd("silent! !rm -r " .. dir.Java_Workspaces)
end

function M.Views()
	local fold_tmp_dir = dir.Data_Dir.."view/"
	vim.cmd("silent! !rm -r " .. fold_tmp_dir)
end

function M.LSP_Log()
	vim.cmd("silent! !rm -r " .. dir.Data_Dir .. "lsp.log")
end

return M

