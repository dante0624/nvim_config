-- We only want our session manager to work when vim was invoked with no arguments
if vim.v.argv[3] ~= nil then
	return
end

local dir = require("utils.directories")
local hud = require("core.myModules.headsUpDisplay")

-- Also make the session load and restore name only depend on the starting directory
local initial_directory = vim.fn.getcwd()

local session_file_name = dir.serialize_path(initial_directory) .. ".vim"
local full_session_path = dir.Sessions .. session_file_name
local source_file = vim.fn.fnameescape(full_session_path) -- Add in needed escape characters

-- Make sure the the desired directory exists
vim.fn.mkdir(dir.Sessions, "p")

-- Need to save global options when we make a session, to restore extra information
vim.opt.sessionoptions:append('globals')

local session_group = vim.api.nvim_create_augroup('sessions', {clear = true})
vim.api.nvim_create_autocmd({'VimLeavePre',}, {
	pattern = "*",
	group = session_group,

	callback = function()
		-- Save barbar order of buffers
		vim.api.nvim_exec_autocmds('User', {pattern = 'SessionSavePre'})

		-- Save the HUD state
		for _, display in pairs(hud) do
			display.save()
		end

		-- Actually save the session file
		-- Put all pre_save logic before this
		vim.cmd("mks! " .. source_file)
	end,
})

vim.api.nvim_create_autocmd({'VimEnter',}, {
	pattern = "*",
	group = session_group,

	callback = function ()
		-- In the event where no file was restored, return from the function early
		if vim.fn.filereadable(full_session_path) == 0 then
			return
		end

		-- Actually restore the session file
		-- Put all post_restore logic after this
		vim.cmd("silent! source " .. source_file)

		-- Sometimes restoring the file messes with the cwd, set it back to what it should be
		vim.cmd('silent! bufdo cd' .. initial_directory)
		local starting_buffer = vim.fn.bufnr()
		vim.cmd('buffer ' .. starting_buffer)

		-- Sometimes neo-tree will leave behind a buffer of itself, delete this if accidentally restored
		for _, buf in ipairs(vim.fn.getbufinfo()) do

			-- Lua uses % to escape characters with string.find
			if buf.name:find("neo%-tree filesystem") ~= nil then
				vim.cmd("bd ".. buf.bufnr)
			end
		end

		-- Restore the HUD state
		for _, display in pairs(hud) do
			display.restore()
		end

	end,
	nested = true,
})

