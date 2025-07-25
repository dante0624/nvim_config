local M = {}

local function is_arm()
	local ok, uname_process = pcall(
		vim.system,
		{'uname', '-p'},
		{ text = true }
	)

	if not ok then
		return false
	end

	local processor_architecture = uname_process:wait().stdout
	if processor_architecture == nil then
		return false
	end

	return processor_architecture:find("arm") ~= nil
end

-- Use flag with if statements to guard architecture specific lines of code
M.is_arm = is_arm()

return M

