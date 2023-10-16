local M = {}
local os = require("utils.os")

-- Flags that we can use in other files that depend on the current shell specifics
local function set_flags()
	M.is_powershell = vim.o.shell:find("powershell") ~= nil
	M.is_cmd = vim.o.shell:find("cmd.exe") ~= nil -- Windows command line (default for windows)
	M.is_bash = vim.o.shell:find("bash") ~= nil
	M.is_zsh = vim.o.shell:find("zsh") ~= nil
end

function M.set_shell()
	local powershell_options = {
		shell = "powershell",
		shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
		shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
		shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
		shellquote = "",
		shellxquote = "",
	}

	if os.is_windows then
		for option, value in pairs(powershell_options) do
		  vim.opt[option] = value
		end
	end

	set_flags() -- Reset the flags cuz we just changed stuff
end

set_flags() -- This sets the flag at startup time, before plugins might change it
return M

