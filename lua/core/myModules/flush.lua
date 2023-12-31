local paths = require("utils.paths")
Flush = {}

-- Contains the functions which flush out an single, set of tmp files
-- These set of tmp files together all serve a single purpose
local single_flush = {}

function single_flush.Java_Workspaces()
	vim.cmd("!rm -r " .. paths.Java_Workspaces)
end

function single_flush.Views()
	vim.cmd("!rm -r " .. paths.Logs_Path .. "view/")
end

function single_flush.LSP_Log()
	vim.cmd("!rm -r " .. paths.Logs_Path .. "lsp.log")
end

function single_flush.Sessions()
	vim.cmd("!rm -r " .. paths.Sessions)
end

function Flush.All()
	for _, func in pairs(single_flush) do
		func()
	end
end

Flush = vim.tbl_extend("keep", Flush, single_flush)
