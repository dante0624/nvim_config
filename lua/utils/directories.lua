local M = {}

M.Data_Dir = vim.fn.fnamemodify(vim.fn.expand('$NVIM_LOG_FILE'), ":h") .. '/' -- Safe way to make work on powershell and wsl
M.Java_Workspaces = M.Data_Dir .. "Java_Workspaces/"

return M

