local M = {}

-- Flags that we can use in other files to came the Nvim config work on all OS versions
M.is_unix = vim.fn.has("unix") == 1
M.is_macos = vim.fn.has("mac") == 1
M.is_wsl = vim.fn.has("wsl") == 1
-- false for WSL
M.is_windows = vim.fn.has("win32") == 1

return M

