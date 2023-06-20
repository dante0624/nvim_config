local M = {}

-- Flags that we can use in other files to came the Nvim config work on all OS versions
M.is_unix = vim.fn.has("unix") == 1
M.is_macos = vim.fn.has("mac") == 1
M.is_windows = vim.fn.has("win32") == 1
M.is_wsl = vim.fn.has("wsl") == 1

-- WSL likes to also set the is_unix flag to true, so manually disable it
if M.is_wsl then
	M.is_unix = false
	M.is_macos = false
	M.is_windows = false
end

return M

