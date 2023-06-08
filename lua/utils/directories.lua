local M = {}

M.Logs_Dir = vim.fn.fnamemodify(vim.fn.stdpath("log"), ":p")
M.Data_Dir = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")
M.Java_Workspaces = M.Data_Dir .. "Java_Workspaces/"

return M

