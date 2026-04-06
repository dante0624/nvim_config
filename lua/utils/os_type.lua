local M = {}

-- Use these flags with if statements to guard OS specific lines of code
M.is_linux_os = vim.fn.has("unix") == 1
M.is_macos = vim.fn.has("mac") == 1
M.is_windows = vim.fn.has("win32") == 1
M.is_wsl = vim.fn.has("wsl") == 1

-- WSL likes to also set the is_unix flag to true, so manually disable it
if M.is_wsl then
	M.is_linux_os = false
	M.is_macos = false
	M.is_windows = false
end

-- MacOS likes to also set the is_unix flag to true, so manually disable it
if M.is_macos then
	M.is_linux_os = false
	M.is_windows = false
	M.is_wsl = false
end

return M
